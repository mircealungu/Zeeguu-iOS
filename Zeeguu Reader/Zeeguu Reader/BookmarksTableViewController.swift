//
//  BookmarksTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-01-16.
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
import ZeeguuAPI

class BookmarksTableViewController: ZGTableViewController {

	var bookmarks = [[Bookmark]]()
	var dates = [String]()
	
	convenience init() {
		self.init(style: .Plain)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 80
		
		self.title = "BOOKMARKS".localized
		
		ZeeguuAPI.sharedAPI().getBookmarksByDayWithContext(true) { (dict) -> Void in
			if let d = dict?.array {
				var counter = 0
				
				for arr in d {
					self.bookmarks.append([Bookmark]())
					let date: String = arr["date"].stringValue
					if let bms = arr["bookmarks"].array {
						for bm in bms {
							let from = bm["from"].stringValue
							let fromLang = bm["from_lang"].stringValue
							let title = bm["title"].stringValue
							let toLang = bm["to_lang"].stringValue
							let context = bm["context"].stringValue
							let to = bm["to"].arrayObject
							let url = bm["url"].stringValue
							
							self.bookmarks[counter].append(Bookmark(title: title, context: context, url: url, bookmarkDate: date, word: from, wordLanguage: fromLang, translation: to as! [String], translationLanguage: toLang))
						}
					}
					self.dates.append(date)
					++counter
				}
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.tableView.reloadData()
				})
			}
		}
		self.clearsSelectionOnViewWillAppear = true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
//	func addNewsFeed(sender: AnyObject) {
//		let addView = AddFeedTableViewController(delegate: self)
//		let nav = UINavigationController(rootViewController: addView)
//		self.presentViewController(nav, animated: true, completion: nil)
//	}
//	
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
	
	func addFeedDidCancel() {
		
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return bookmarks.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookmarks[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell")
		var cell: UITableViewCell
		if let c = queueCell {
			cell = c
		} else {
			cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
		}
		
		let feed = bookmarks[indexPath.section][indexPath.row]
		cell.textLabel?.text = feed.word
		cell.detailTextLabel?.text = feed.translation[0]
		cell.accessoryType = .DisclosureIndicator
		
		return cell
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let formatter = NSDateFormatter()
		formatter.dateStyle = .LongStyle
		formatter.timeStyle = .NoStyle
		print("original date: \(self.dates[section])")
		return formatter.stringFromDate(self.bookmarks[section][0].date)
	}
	
//	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//		if editingStyle == .Delete {
//			self.newsFeeds.removeAtIndex(indexPath.row)
//			let def = NSUserDefaults.standardUserDefaults()
//			
//			var feeds = self.newsFeeds
//			feeds.removeFirst()
//			def.setObject(feeds, forKey: feedsKey)
//			
//			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//		}
//	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//		let feed = self.newsFeeds[indexPath.row]
		let vc = ArticleListViewController()
		
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
