//
//  HistoryTableViewController.swift
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
import Zeeguu_API_iOS

class HistoryTableViewController: ZGTableViewController {

	var bookmarks = [[Bookmark]]()
	var dates = [String]()
	
	private let estimatedRowHeight: CGFloat = 80
	
	convenience init() {
		self.init(style: .Plain)
		
		self.tabBarItem = UITabBarItem(title: nil, image: AppIcon.historyIcon(), selectedImage: AppIcon.historyIcon(true))
		self.title = "HISTORY".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = estimatedRowHeight
		
		self.clearsSelectionOnViewWillAppear = true
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(HistoryTableViewController.getBookmarks), forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		getBookmarks()
		
		let selector = #selector(HistoryTableViewController.getBookmarksForNotification(_:))
		NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UserTranslatedWordNotification, object: nil)
	}
	
	func getBookmarksForNotification(notification: NSNotification) {
		self.refreshControl?.beginRefreshing()
		self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
		getBookmarks()
	}
	
	func getBookmarks() {
		ZeeguuAPI.sharedAPI().getBookmarksByDayWithContext(true) { (dict) -> Void in
			var items = [[Bookmark]]()
			var filled = false
			if let d = dict?.array {
				var counter = 0
				
				for arr in d {
					items.append([Bookmark]())
					let date: String = arr["date"].stringValue
					if let bms = arr["bookmarks"].array {
						for bm in bms {
							let id = bm["id"].stringValue
							let from = bm["from"].stringValue
							let fromLang = bm["from_lang"].stringValue
							let title = bm["title"].stringValue
							let toLang = bm["to_lang"].stringValue
							let context = bm["context"].stringValue
							let to = bm["to"].arrayObject
							let url = bm["url"].stringValue
							
							items[counter].append(Bookmark(id: id, title: title, context: context, url: url, bookmarkDate: date, word: from, wordLanguage: fromLang, translation: to as! [String], translationLanguage: toLang))
						}
					}
					self.dates.append(date)
					counter += 1
				}
				filled = true
			}
			// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
			// This enables us to attach a completion block to the animation, reloading data before
			// animation is complete causes glitching.
			CATransaction.begin()
			CATransaction.setCompletionBlock({ () -> Void in
				if filled {
					self.bookmarks = items
				}
				self.tableView.reloadData()
			})
			self.refreshControl?.endRefreshing()
			CATransaction.commit()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return bookmarks.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookmarks[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let sec = indexPath.section
		let row = indexPath.row
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell")
		var cell: HistoryTableViewCell
		
		let bookmark = bookmarks[sec][row]
		if let c = queueCell as? HistoryTableViewCell {
			cell = c
			cell.bookmark = bookmark
		} else {
			cell = HistoryTableViewCell(bookmark: bookmark, reuseIdentifier: "Cell")
		}
		
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
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			let sec = indexPath.section
			let row = indexPath.row
			let bm = self.bookmarks[sec][row]
			bm.delete() { (success) in
				if (success) {
					dispatch_async(dispatch_get_main_queue(), { 
						self.bookmarks[sec].removeAtIndex(row)
						tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
					})
				}
			}
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let bookmark = self.bookmarks[indexPath.section][indexPath.row]
		
		let vc = HistoryItemViewController(bookmark: bookmark)
		
		self.navigationController?.pushViewController(vc, animated: true)
		
		Utils.sendMonitoringStatusToServer("userOpensHistoryItem", value: "1")
	}

}
