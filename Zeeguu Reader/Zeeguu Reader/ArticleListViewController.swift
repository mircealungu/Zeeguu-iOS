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
	var loadedAllContents = false
	
	convenience init(feed: Feed) {
		self.init(feeds: [feed])
	}
	
	convenience init(feeds: [Feed]) {
		self.init()
		self.feeds = feeds
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
		let def = NSUserDefaults.standardUserDefaults()
		
		for i in 0 ..< feeds.count {
			if let arr = def.objectForKey(articlesForFeedKey + feeds[i].id!) as? [[String: AnyObject]], arts = ZGSerialize.decodeArray(arr) as? [Article] {
				self.articles = self.mergeArticles(oldArticles:self.articles, newArticles: arts)
			}
		}
		
		self.reloadTableView()
		
		for i in 0 ..< feeds.count {
			ZeeguuAPI.sharedAPI().getFeedItemsForFeed(feeds[i], completion: { (articles) -> Void in
				if let arts = articles {
					self.articles = self.mergeArticles(oldArticles:self.articles, newArticles: arts)
					self.saveArticles(arts, forKey: articlesForFeedKey + self.feeds[i].id!)
				}
				if i == self.feeds.count - 1 {
					self.reloadTableView()
				}
			})
		}
	}
	
	func mergeArticles(oldArticles oldArticles: [Article], newArticles: [Article], reload: Bool = true) -> [Article] {
		var oldArticles = oldArticles
		for art in newArticles {
			if !oldArticles.contains({ $0 == art }) {
				oldArticles.append(art);
			}
		}
		oldArticles.sortInPlace({ (lhs, rhs) -> Bool in
			return lhs.date > rhs.date
		})
		return oldArticles
	}
	
	func replaceArticles(oldArticles oldArticles: [Article], newArticles: [Article], reload: Bool = true) -> [Article] {
		var oldArticles = oldArticles
		for art in newArticles {
			if oldArticles.contains({ $0 == art }) {
				oldArticles[oldArticles.indexOf(art)!] = art
			}
		}
		oldArticles.sortInPlace({ (lhs, rhs) -> Bool in
			return lhs.date > rhs.date
		})
		return oldArticles
	}
	
	func saveArticles(articles: [Article], forKey key: String) {
		let def = NSUserDefaults.standardUserDefaults()
		if let arr = def.objectForKey(key) as? [[String: AnyObject]], localArts = ZGSerialize.decodeArray(arr) as? [Article] {
			let newLocal = self.replaceArticles(oldArticles: localArts, newArticles: articles)
			def.setObject(ZGSerialize.encodeArray(newLocal), forKey: key)
		} else {
			def.setObject(ZGSerialize.encodeArray(articles), forKey: key)
		}
		def.synchronize()
	}
	
	func updateLocalArticles(arts: [Article]) {
		var allArticles = [[Article]]()
		
		for _ in feeds {
			allArticles.append([Article]())
		}
		
		for a in arts {
			allArticles[feeds.indexOf(a.feed)!].append(a)
		}
		
		for i in 0 ..< feeds.count {
			saveArticles(allArticles[i], forKey: articlesForFeedKey + feeds[i].id!)
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
					self.updateLocalArticles(self.articles)
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
		updateLocalArticles(articles)
		tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
		let article = articles[indexPath.row]
		let vc = ArticleViewController(article: article)
		
		var controllers = split.viewControllers
		controllers.removeLast()
		
		let nav = UINavigationController(rootViewController: vc)
		
		vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		vc.navigationItem.leftItemsSupplementBackButton = true
		split.showDetailViewController(nav, sender: self)
		UIApplication.sharedApplication().sendAction(split.displayModeButtonItem().action, to: split.displayModeButtonItem().target, from: nil, forEvent: nil)
		Utils.sendMonitoringStatusToServer("userOpensArticle", value: "1")
	}
}

