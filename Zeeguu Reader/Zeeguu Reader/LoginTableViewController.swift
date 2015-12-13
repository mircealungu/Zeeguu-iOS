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
import ZeeguuAPI

class LoginTableViewController: UITableViewController {
	let rows = ["EMAIL".localized, "PASSWORD".localized]
	
	let emailField = UITextField.autoLayoutCapapble()
	let passwordField = UITextField.autoLayoutCapapble()
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.title = "LOGIN".localized
		let loginButton = UIBarButtonItem(title: "LOGIN".localized, style: .Done, target: self, action: "login:")
		self.navigationItem.rightBarButtonItem = loginButton
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setupTextFields()
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
	
	func login(sender: UIBarButtonItem) {
		let email = emailField.text
		let password = passwordField.text
		
		if let em = email, pw = password {
			ZeeguuAPI.sharedAPI().loginWithEmail(em, password: pw) { (success) -> Void in
				if (success) {
					self.dismissViewControllerAnimated(true, completion: nil)
				} else {
					Utils.showOKAlertWithTitle("LOGIN_FAILED".localized, message: "LOGIN_FAILED_MESSAGE".localized, okAction: nil)
				}
			}
		} else {
			Utils.showOKAlertWithTitle("NO_LOGIN".localized, message: "NO_LOGIN_MESSAGE".localized, okAction: nil)
		}
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
