//
//  FindingFeedsTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 18-01-16.
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

class FindingFeedsTableViewController: ZGTableViewController {
	var rows = [Feed]()
	var selectedFeeds = NSMutableArray()
	var feedURL = ""
	
	var delegate: AddFeedTableViewControllerDelegate?
	
	convenience init(feedURL: String, delegate: AddFeedTableViewControllerDelegate?) {
		self.init(style: .Grouped)
		self.delegate = delegate
		self.feedURL = feedURL
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "ADD_FEED".localized
		
		let addButton = UIBarButtonItem(title: "ADD".localized, style: .Done, target: self, action: "addFeeds:")
		addButton.enabled = false
		self.navigationItem.rightBarButtonItem = addButton
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "findFeeds", forControlEvents: .ValueChanged)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "FINDING_FEEDS".localized)
		self.refreshControl?.beginRefreshing()
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 80
		
		findFeeds()
	}
	
	func findFeeds() {
		ZeeguuAPI.sharedAPI().getFeedsAtUrl(self.feedURL) { (feeds) -> Void in
			if let feeds = feeds {
				self.rows = feeds
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
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let feed = rows[indexPath.row]
		let cellTitle = feed.title
		var cell = tableView.dequeueReusableCellWithIdentifier(cellTitle) as? FeedTableViewCell
		if (cell == nil) {
//			cell = UITableViewCell(style: .Default, reuseIdentifier: cellTitle)
//			if (indexPath.row == 0) {
//				cell = ZGTextFieldTableViewCell(title: cellTitle, textField: urlField, reuseIdentifier: cellTitle)
//			}
			cell = FeedTableViewCell(reuseIdentifier: cellTitle)
		}
		
		cell?.title = feed.title
		cell?.feedDescription = feed.feedDescription
		feed.getImage { (image) -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				cell?.feedImage = image
			})
		}
		
		cell?.selectionStyle = .None
		
//		cell?.textLabel?.text = cellTitle
		
		
		// Configure the cell...
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "CHOOSE_FEEDS_TO_ADD".localized
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let feed = rows[indexPath.row]
		if selectedFeeds.containsObject(feed) {
			selectedFeeds.removeObject(feed)
			tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
		} else {
			selectedFeeds.addObject(feed)
			tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.navigationItem.rightBarButtonItem?.enabled = Bool(selectedFeeds.count)
	}
	
	func addFeeds(sender: UIBarButtonItem) {
		var urls = [String]()
		for feed in selectedFeeds {
			if let feed = feed as? Feed {
				urls.append(feed.url)
			}
		}
		ZeeguuAPI.sharedAPI().startFollowingFeeds(urls) { (success) -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.dismissViewControllerAnimated(true, completion: { () -> Void in
					self.delegate?.addFeedDidAddFeeds(self.selectedFeeds as [AnyObject] as! [Feed])
				})
			})
		}
	}
	
	func cancel(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			self.delegate?.addFeedDidCancel()
		})
	}
	
}
