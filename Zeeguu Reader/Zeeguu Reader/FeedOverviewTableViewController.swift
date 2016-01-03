//
//  FeedOverviewTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 02-01-16.
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

let feedsKey = "newsFeeds"

class FeedOverviewTableViewController: ZGTableViewController, AddFeedTableViewControllerDelegate {

	var newsFeeds = [String]()
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.tabBarItem = UITabBarItem(title: "APP_TITLE".localized, image: UIImage(named: "feedsIcon"), selectedImage: UIImage(named: "feedsIconActive"))
		self.title = "APP_TITLE".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 80
		
		let def = NSUserDefaults.standardUserDefaults()
		if let feeds = def.objectForKey(feedsKey) {
			self.newsFeeds = feeds as! [String]
			if self.newsFeeds.count != 0 {
				self.newsFeeds.insert("ALL_FEEDS".localized, atIndex: 0)
			}
		} else {
			def.setObject(self.newsFeeds, forKey: feedsKey)
		}
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewsFeed:")
		self.navigationItem.rightBarButtonItem = addButton
		
//		let logoutButton = UIBarButtonItem(title: "LOGOUT".localized, style: .Done, target: self, action: "logout:")
//		self.navigationItem.leftBarButtonItem = logoutButton
		self.clearsSelectionOnViewWillAppear = true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func addNewsFeed(sender: AnyObject) {
		let addView = AddFeedTableViewController(delegate: self)
		let nav = UINavigationController(rootViewController: addView)
		self.presentViewController(nav, animated: true, completion: nil)
	}
	
	func addFeed(feed: String) {
		self.newsFeeds.append(feed)
		let def = NSUserDefaults.standardUserDefaults()
		
		var feeds = self.newsFeeds
		if (feeds.count > 1) {
			feeds.removeFirst()
		} else {
			self.newsFeeds.insert("ALL_FEEDS".localized, atIndex: 0)
		}
		def.setObject(feeds, forKey: feedsKey)
		self.tableView.reloadData()
	}
	
	func addFeedDidCancel() {
		
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsFeeds.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell")
		var cell: UITableViewCell
		if let c = queueCell {
			cell = c
		} else {
			cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
		}
		
		let feed = newsFeeds[indexPath.row]
		cell.textLabel?.text = feed
		cell.accessoryType = .DisclosureIndicator
		
		return cell
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			self.newsFeeds.removeAtIndex(indexPath.row)
			let def = NSUserDefaults.standardUserDefaults()
			
			var feeds = self.newsFeeds
			feeds.removeFirst()
			def.setObject(feeds, forKey: feedsKey)
			
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//		let feed = self.newsFeeds[indexPath.row]
		let vc = ArticleListViewController()
		
//		if let split = self.splitViewController {
//			var controllers = split.viewControllers
//			controllers.removeLast()
//			
//			let nav = UINavigationController(rootViewController: vc)
//			
//			vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//			vc.navigationItem.leftItemsSupplementBackButton = true
//			split.showDetailViewController(nav, sender: self)
//			if let sv = self.splitViewController {
//				UIApplication.sharedApplication().sendAction(sv.displayModeButtonItem().action, to: sv.displayModeButtonItem().target, from: nil, forEvent: nil)
//			}
//		} else {
//			vc.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(vc, animated: true)
//		}
	}

}
