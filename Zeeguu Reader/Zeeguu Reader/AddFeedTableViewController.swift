//
//  AddFeedTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 01-01-16.
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

class AddFeedTableViewController: UITableViewController, UITextFieldDelegate {
	var rows: [[AnyObject]] = [["URL".localized]]
	
	let urlField = UITextField.autoLayoutCapable()
	var delegate: AddFeedTableViewControllerDelegate?
	
	convenience init(delegate: AddFeedTableViewControllerDelegate) {
		self.init(style: .Grouped)
		self.delegate = delegate
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTextFields()
		
		self.title = "ADD_FEED".localized
		
		let addButton = UIBarButtonItem(title: "ADD".localized, style: .Done, target: self, action: #selector(AddFeedTableViewController.addFeed(_:)))
		addButton.enabled = false
		self.navigationItem.rightBarButtonItem = addButton
		
		let cancelButton = UIBarButtonItem(title: "CANCEL".localized, style: .Plain, target: self, action: #selector(AddFeedTableViewController.cancel(_:)))
		self.navigationItem.leftBarButtonItem = cancelButton
		
		let textFieldChangedSelector = #selector(AddFeedTableViewController.textFieldChanged(_:))
		NSNotificationCenter.defaultCenter().addObserver(self, selector: textFieldChangedSelector, name: UITextFieldTextDidChangeNotification, object: urlField)
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 80
		
		ZeeguuAPI.sharedAPI().getLearnedLanguage { (langCode) in
			if let lc = langCode {
				ZeeguuAPI.sharedAPI().getInterestingFeeds(lc) { (feeds) in
					if let fs = feeds where fs.count > 0 {
						self.rows.append(fs)
						dispatch_async(dispatch_get_main_queue(), { 
							self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
						})
					}
				}
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		urlField.becomeFirstResponder()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return rows.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let sec = indexPath.section
		let row = indexPath.row
		
		let object = rows[sec][row]
		var cell: UITableViewCell!
		
		if sec == 0 {
			cell = tableView.dequeueReusableCellWithIdentifier("cell")
			if cell == nil {
				if let cellTitle = object as? String where indexPath.row == 0 {
					cell = ZGTextFieldTableViewCell(title: cellTitle, textField: urlField, reuseIdentifier: "cell")
				}
			}
		} else if sec == 1 {
			var c = tableView.dequeueReusableCellWithIdentifier("feed") as? FeedTableViewCell
			if let f = object as? Feed {
				if c == nil {
					c = FeedTableViewCell(feed: f, reuseIdentifier: "feed")
				} else {
					c?.feed = f
				}
				cell = c
				cell.accessoryType = .DisclosureIndicator
			}
		}
		
		// Configure the cell...
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let sec = indexPath.section
		let row = indexPath.row
		
		if sec == 0 {
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		} else if sec == 1 {
			if let feed = rows[sec][row] as? Feed {
				ZeeguuAPI.sharedAPI().enableDebugOutput = true
				ZeeguuAPI.sharedAPI().startFollowingFeeds([feed.url]) { (success) -> Void in
					ZeeguuAPI.sharedAPI().enableDebugOutput = false
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.delegate?.addFeedDidAddFeeds([feed])
						self.dismissViewControllerAnimated(true, completion: nil)
					})
				}
			}
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "INTERESTING_FEEDS".localized
		}
		return nil
	}
	
	func textFieldChanged(notification: NSNotification) {
		self.navigationItem.rightBarButtonItem?.enabled = urlField.text?.characters.count > "http://".characters.count
	}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if (textField != urlField) {
			return true
		}
		if let t = textField.text {
			let newString: NSString = NSString(string: t).stringByReplacingCharactersInRange(range, withString: string)
			let http: NSString = "http://"
			if (newString.length < http.length) {
				return false
			} else if (!newString.hasPrefix(http as String)) {
				return false
			}
		}
		return true
	}
	
	func setupTextFields() {
		urlField.placeholder = "URL".localized
		urlField.text = "http://"
		urlField.delegate = self
		urlField.keyboardType = .URL
		urlField.returnKeyType = .Done
		urlField.autocapitalizationType = .None
		urlField.adjustsFontSizeToFitWidth = true
		urlField.addTarget(self, action: #selector(AddFeedTableViewController.textFieldEnterPressed(_:)), forControlEvents: .EditingDidEndOnExit)
	}
	
	func textFieldEnterPressed(textField: UITextField) {
		if textField.isEqual(urlField) {
			addFeed(self.navigationItem.rightBarButtonItem!)
		}
	}
	
	func addFeed(sender: UIBarButtonItem) {
		let feed = urlField.text
		
		if let f = feed {
			let vc = SelectFeedsTableViewController(feedURL: f, delegate: delegate)
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func cancel(sender: UIBarButtonItem) {
		urlField.resignFirstResponder()
		self.delegate?.addFeedDidCancel()
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}



protocol AddFeedTableViewControllerDelegate {
	
	func addFeedDidAddFeeds(feeds: [Feed])
	func addFeedDidCancel()
	
}
