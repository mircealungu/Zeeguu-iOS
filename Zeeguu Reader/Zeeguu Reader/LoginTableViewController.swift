//
//  LoginTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 12-12-15.
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

class LoginTableViewController: ZGTableViewController {
	let rows = ["EMAIL".localized, "PASSWORD".localized]
	
	let emailField = UITextField.autoLayoutCapable()
	let passwordField = UITextField.autoLayoutCapable()
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.title = "LOGIN".localized
		let loginButton = UIBarButtonItem(title: "LOGIN".localized, style: .Done, target: self, action: #selector(LoginTableViewController.login(_:)))
		self.navigationItem.rightBarButtonItem = loginButton
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupTextFields()
		
		ZGSharedPasswordManager.retrieveSharedCredentials { (email, password) in
			guard let email = email, password = password else {
				return
			}
			self.emailField.text = email
			self.passwordField.text = password
			self.login(nil)
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
		let cellTitle = rows[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellTitle)
		if (cell == nil) {
			if (indexPath.row == 0) {
				cell = ZGTextFieldTableViewCell(title: cellTitle, textField: emailField, reuseIdentifier: cellTitle)
			} else if (indexPath.row == 1) {
				cell = ZGTextFieldTableViewCell(title: cellTitle, textField: passwordField, reuseIdentifier: cellTitle)
			}
			
		}

        // Configure the cell...

        return cell!
    }
	
	func setupTextFields() {
		emailField.placeholder = "EMAIL".localized
		emailField.keyboardType = .EmailAddress
		emailField.autocapitalizationType = .None
		emailField.adjustsFontSizeToFitWidth = true
		
		passwordField.placeholder = "PASSWORD".localized
		passwordField.secureTextEntry = true
	}
	
	func login(sender: UIBarButtonItem?) {
		let email = emailField.text
		let password = passwordField.text
		
		if let em = email, pw = password {
			ZeeguuAPI.sharedAPI().loginWithEmail(em, password: pw) { (success) -> Void in
				dispatch_async(dispatch_get_main_queue(), {
					if (success) {
						ZGSharedPasswordManager.updateSharedCredentials(em, password: pw)
						self.dismissViewControllerAnimated(true, completion: {
							NSNotificationCenter.defaultCenter().postNotificationName(UserLoggedInNotification, object: self)
						})
					} else {
						Utils.showOKAlertWithTitle("LOGIN_FAILED".localized, message: "LOGIN_FAILED_MESSAGE".localized, okAction: nil)
					}
				})
			}
		} else {
			Utils.showOKAlertWithTitle("NO_LOGIN".localized, message: "NO_LOGIN_MESSAGE".localized, okAction: nil)
		}
	}
}
