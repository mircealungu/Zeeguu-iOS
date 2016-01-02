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

class AddFeedTableViewController: UITableViewController {
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
		self.navigationItem.rightBarButtonItem = addButton
		
		let cancelButton = UIBarButtonItem(title: "CANCEL".localized, style: .Plain, target: self, action: "cancel:")
		self.navigationItem.leftBarButtonItem = cancelButton
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
	
	func setupTextFields() {
		urlField.placeholder = "URL".localized
		urlField.keyboardType = .URL
		urlField.autocapitalizationType = .None
		urlField.adjustsFontSizeToFitWidth = true
	}
	
	func addFeed(sender: UIBarButtonItem) {
		let feed = urlField.text
		
		if let f = feed {
			self.dismissViewControllerAnimated(true, completion: { () -> Void in
				self.delegate?.addFeed(f)
			})
		}
	}
	
	func cancel(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			self.delegate?.addFeedDidCancel()
		})
	}

}



protocol AddFeedTableViewControllerDelegate {
	
	func addFeed(feed:String)
	func addFeedDidCancel()
	
}
