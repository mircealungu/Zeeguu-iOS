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
import ZeeguuAPI

class AddFeedTableViewController: UITableViewController, UITextFieldDelegate {
	let rows = ["URL".localized]
	
	let urlField = UITextField.autoLayoutCapapble()
	var delegate: AddFeedTableViewControllerDelegate?
	
	convenience init(delegate: AddFeedTableViewControllerDelegate) {
		self.init(style: .Grouped)
		self.delegate = delegate
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTextFields()
		
		self.title = "ADD_FEED".localized
		
		let addButton = UIBarButtonItem(title: "ADD".localized, style: .Done, target: self, action: "addFeed:")
		addButton.enabled = false
		self.navigationItem.rightBarButtonItem = addButton
		
		let cancelButton = UIBarButtonItem(title: "CANCEL".localized, style: .Plain, target: self, action: "cancel:")
		self.navigationItem.leftBarButtonItem = cancelButton
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldChanged:", name: UITextFieldTextDidChangeNotification, object: urlField)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		urlField.becomeFirstResponder()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cellTitle = rows[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellTitle)
		if (cell == nil) {
			if (indexPath.row == 0) {
				cell = ZGTextFieldTableViewCell(title: cellTitle, textField: urlField, reuseIdentifier: cellTitle)
			}
			
		}
		
		// Configure the cell...
		
		return cell!
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
		urlField.addTarget(self, action: "textFieldEnterPressed:", forControlEvents: .EditingDidEndOnExit)
	}
	
	func textFieldEnterPressed(textField: UITextField) {
		if textField.isEqual(urlField) {
			addFeed(self.navigationItem.rightBarButtonItem!)
		}
	}
	
	func addFeed(sender: UIBarButtonItem) {
		let feed = urlField.text
		
		if let f = feed {
			let vc = FindingFeedsTableViewController(feedURL: f, delegate: delegate)
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func cancel(sender: UIBarButtonItem) {
		urlField.resignFirstResponder()
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			self.delegate?.addFeedDidCancel()
		})
	}

}



protocol AddFeedTableViewControllerDelegate {
	
	func addFeedDidAddFeeds(feeds: [Feed])
	func addFeedDidCancel()
	
}
