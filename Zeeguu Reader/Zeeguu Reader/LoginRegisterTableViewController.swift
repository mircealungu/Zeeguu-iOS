//
//  LoginRegisterTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 13-12-15.
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

class LoginRegisterTableViewController: ZGTableViewController {
	let rows = ["LOGIN".localized, "REGISTER".localized]
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.title = "LOGIN_OR_REGISTER".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
			cell = UITableViewCell(style: .Default, reuseIdentifier: cellTitle)
		}
		cell?.textLabel?.text = cellTitle
		cell?.accessoryType = .DisclosureIndicator
		
		// Configure the cell...
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if (indexPath.row == 0) {
			self.navigationController?.pushViewController(LoginTableViewController(), animated: true)
		} else if (indexPath.row == 1) {
			self.navigationController?.pushViewController(RegisterTableViewController(), animated: true)
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
