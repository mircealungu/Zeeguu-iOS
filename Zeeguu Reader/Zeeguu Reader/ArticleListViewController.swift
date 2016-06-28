//
//  MasterViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Zeeguu_API_iOS

class ArticleListViewController: ZGTableViewController {
	
	var feed: Feed?
	var articles = [Article]()
	var loadedAllContents = false
	
	init(feed: Feed? = nil) {
		self.feed = feed
		super.init(style: .Plain)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 100
		
		self.title = "NEWS".localized
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			self.clearsSelectionOnViewWillAppear = true
		}
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(ArticleListViewController.getArticles), forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		getArticles()
	}
	
	func getArticles() {
		self.articles = ArticleManager.sharedManager().getArticles(self.feed)
		
		self.reloadTableView()
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
			self.articles = ArticleManager.sharedManager().downloadArticles(self.feed)
			dispatch_async(dispatch_get_main_queue(), {
				self.reloadTableView()
			})
		}
	}
	
	func reloadTableView() {
		// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
		// This enables us to attach a completion block to the animation, reloading data before
		// animation is complete causes glitching.
		CATransaction.begin()
		CATransaction.setCompletionBlock({ () -> Void in
			self.tableView.reloadData()
			self.getDifficulties()
		})
		self.refreshControl?.endRefreshing()
		CATransaction.commit()
	}
	
	func getDifficulties() {
		Article.getDifficultiesForArticles(self.articles) { (success) in
			print("get difficulty success: \(success)")
			if success {
				dispatch_async(dispatch_get_main_queue(), {
					ArticleManager.sharedManager().updateLocalArticles(self.articles)
					self.tableView.reloadData()
				})
			}
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return articles.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell") as? ArticleTableViewCell
		
		let article = articles[indexPath.row]
		var cell: ArticleTableViewCell
		if let c = queueCell {
			cell = c
			cell.setArticle(article)
		} else {
			cell = ArticleTableViewCell(article: article, reuseIdentifier: "Cell")
		}
		
		// TODO: Disabled this for now as not all images seem to correspond to the main image
		//		if self.loadedAllContents {
		//			article.getImage({ (image) in
		//				if let i = image {
		//					dispatch_async(dispatch_get_main_queue(), {
		//						cell.setArticleImage(i)
		//					})
		//				}
		//			})
		//		}
		
		cell.accessoryType = .DisclosureIndicator
		return cell
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			articles.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let split = self.splitViewController else {
			return
		}
		articles[indexPath.row].isRead = true
		ArticleManager.sharedManager().updateLocalArticles(articles)
//		tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		tableView.reloadData()
		let article = articles[indexPath.row]
		let vc = ArticleViewController(article: article)
		
		var controllers = split.viewControllers
		controllers.removeLast()
		
		let nav = UINavigationController(rootViewController: vc)
		
		vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		vc.navigationItem.leftItemsSupplementBackButton = true
		split.showDetailViewController(nav, sender: self)
		UIApplication.sharedApplication().sendAction(split.displayModeButtonItem().action, to: split.displayModeButtonItem().target, from: nil, forEvent: nil)
		ZeeguuAPI.sendMonitoringStatusToServer("userOpensArticle", value: "1")
	}
}

