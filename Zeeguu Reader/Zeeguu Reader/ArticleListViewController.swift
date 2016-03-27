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

	var feeds = [Feed]()
	var articles = [Article]()
	
	convenience init(feed: Feed) {
		self.init(feeds: [feed])
	}
	
	convenience init(feeds: [Feed]) {
		self.init()
		self.feeds = feeds
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 80
		
		self.title = "APP_TITLE".localized
		self.navigationItem.title = "APP_TITLE".localized
		
//		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//		self.navigationItem.rightBarButtonItem = addButton
		
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			self.clearsSelectionOnViewWillAppear = true
		}
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "getArticles", forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		getArticles()
	}
	
	func getArticles() {
		var j = 0;
		for var i = 0; i != feeds.count; ++i {
			ZeeguuAPI.sharedAPI().getFeedItemsForFeed(feeds[i], completion: { (articles) -> Void in
				if let arts = articles {
					self.articles.appendContentsOf(arts)
					self.articles.sortInPlace({ (lhs, rhs) -> Bool in
						return lhs.date > rhs.date
					})
				}
				++j
				if (j == self.feeds.count) {
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
						// This enables us to attach a completion block to the animation, reloading data before
						// animation is complete causes glitching.
						CATransaction.begin()
						CATransaction.setCompletionBlock({ () -> Void in
							self.tableView.reloadData()
						})
						self.refreshControl?.endRefreshing()
						CATransaction.commit()
					})
				}
			})
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func logout(sender: AnyObject) {
		ZeeguuAPI.sharedAPI().logout { (success) -> Void in
			(UIApplication.sharedApplication().delegate as? AppDelegate)?.presentLogin()
		}
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
		let article = articles[indexPath.row]
		let vc = ArticleViewController(article: article)
		
		if let split = self.splitViewController {
			var controllers = split.viewControllers
			controllers.removeLast()
			
			let nav = UINavigationController(rootViewController: vc)
			
			vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
			vc.navigationItem.leftItemsSupplementBackButton = true
			split.showDetailViewController(nav, sender: self)
			if let sv = self.splitViewController {
				UIApplication.sharedApplication().sendAction(sv.displayModeButtonItem().action, to: sv.displayModeButtonItem().target, from: nil, forEvent: nil)
			}
		} else {
			vc.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

