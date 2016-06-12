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

import Zeeguu_API_iOS

class FeedOverviewTableViewController: ZGTableViewController, AddFeedTableViewControllerDelegate {

	var newsFeeds = [AnyObject]()
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.tabBarItem = UITabBarItem(title: "NEWS".localized, image: AppIcon.newsIcon(), selectedImage: AppIcon.newsIcon(true))
		self.title = "NEWS".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let didLoginSelector = #selector(FeedOverviewTableViewController.userDidLogin(_:))
		NSNotificationCenter.defaultCenter().addObserver(self, selector: didLoginSelector, name: UserLoggedInNotification, object: nil)
		
		self.tableView.estimatedRowHeight = 80
		
//		let def = NSUserDefaults.standardUserDefaults()
//		if let feeds = def.objectForKey(feedsKey) {
//			self.newsFeeds = feeds as! [String]
//			if self.newsFeeds.count != 0 {
//				self.newsFeeds.insert("ALL_FEEDS".localized, atIndex: 0)
//			}
//		} else {
//			def.setObject(self.newsFeeds, forKey: feedsKey)
//		}
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(FeedOverviewTableViewController.addNewsFeed(_:)))
		self.navigationItem.rightBarButtonItem = addButton
		
		self.clearsSelectionOnViewWillAppear = true
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(FeedOverviewTableViewController.getFeeds), forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 80
		
		getFeeds()
	}
	
	func getFeeds() {
		ZeeguuAPI.sharedAPI().getFeedsBeingFollowed { (feeds) -> Void in
			if let arr = feeds {
				self.newsFeeds = arr
				
				if (self.newsFeeds.count > 0) {
					self.newsFeeds.insert("ALL_FEEDS".localized, atIndex: 0)
				}
			}
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
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func addNewsFeed(sender: AnyObject) {
		let addView = AddFeedTableViewController(delegate: self)
		let nav = UINavigationController(rootViewController: addView)
		nav.modalPresentationStyle = .FormSheet
		self.presentViewController(nav, animated: true, completion: nil)
	}
	
//	func addFeed(feed: String) {
//		self.newsFeeds.append(feed)
//		let def = NSUserDefaults.standardUserDefaults()
//		
//		var feeds = self.newsFeeds
//		if (feeds.count > 1) {
//			feeds.removeFirst()
//		} else {
//			self.newsFeeds.insert("ALL_FEEDS".localized, atIndex: 0)
//		}
//		def.setObject(feeds, forKey: feedsKey)
//		self.tableView.reloadData()
//	}
	
	func addFeedDidAddFeeds(feeds: [Feed]) {
		self.refreshControl?.beginRefreshing()
		getFeeds()
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
		let feed = newsFeeds[indexPath.row]
		
		if indexPath.row == 0 {
			var cell = tableView.dequeueReusableCellWithIdentifier("ALL_FEEDS")
			if cell == nil {
				cell = UITableViewCell(style: .Default, reuseIdentifier: "ALL_FEEDS")
			}
			cell?.textLabel?.text = feed as? String
			cell?.accessoryType = .DisclosureIndicator
			return cell!
		} else {
			var cell = tableView.dequeueReusableCellWithIdentifier("feed") as? FeedTableViewCell
			if cell == nil {
				cell = FeedTableViewCell(reuseIdentifier: "feed")
			}
			if let f = feed as? Feed {
				cell?.title = f.title
				cell?.feedDescription = f.feedDescription
				f.getImage({ (image) -> Void in
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						cell?.feedImage = image
					})
				})
			}
			cell?.accessoryType = .DisclosureIndicator
			return cell!
		}
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			if let feedID = (self.newsFeeds[indexPath.row] as? Feed)?.id {
				ZeeguuAPI.sharedAPI().stopFollowingFeed(feedID, completion: { (success) -> Void in
					if success {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.newsFeeds.removeAtIndex(indexPath.row)
							tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
						})
					}
				})
			}
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var vc: UIViewController? = nil
		if let _ = newsFeeds[indexPath.row] as? String {
			var arr = newsFeeds
			arr.removeFirst()
			vc = ArticleListViewController(feeds: arr as! [Feed])
		} else if let row = newsFeeds[indexPath.row] as? Feed {
			vc = ArticleListViewController(feed: row)
		}
		if let vc = vc {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func userDidLogin(notification: NSNotification) {
		self.refreshControl?.beginRefreshing()
		getFeeds()
	}

}
