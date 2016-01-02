//
//  RegisterTableViewController.swift
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
import ZeeguuAPI

class RegisterTableViewController: ZGTableViewController, LanguagesTableViewControllerDelegate {
	let rows = [["NAME".localized, "EMAIL".localized, "PASSWORD".localized], ["LEARN_LANGUAGE".localized, "BASE_LANGUAGE".localized]]
	
	let nameField = UITextField.autoLayoutCapapble()
	let emailField = UITextField.autoLayoutCapapble()
	let passwordField = UITextField.autoLayoutCapapble()
	
	var learnLanguage: (String, String)? = nil
	var baseLanguage: (String, String)? = nil
	
	convenience init() {
		self.init(style: .Grouped)
		
		self.title = "REGISTER".localized
		let loginButton = UIBarButtonItem(title: "REGISTER".localized, style: .Done, target: self, action: "register:")
		self.navigationItem.rightBarButtonItem = loginButton
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTextFields()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return rows.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cellTitle = rows[indexPath.section][indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellTitle)
		if (cell == nil) {
			if (indexPath.section == 0) {
				if (indexPath.row == 0) {
					cell = ZGTextFieldTableViewCell(title: cellTitle, textField: nameField, reuseIdentifier: cellTitle)
				} else if (indexPath.row == 1) {
					cell = ZGTextFieldTableViewCell(title: cellTitle, textField: emailField, reuseIdentifier: cellTitle)
				} else if (indexPath.row == 2) {
					cell = ZGTextFieldTableViewCell(title: cellTitle, textField: passwordField, reuseIdentifier: cellTitle)
				}
			} else if (indexPath.section == 1) {
				if (indexPath.row == 0) {
					cell = UITableViewCell(style: .Value1, reuseIdentifier: cellTitle)
				} else if (indexPath.row == 1) {
					cell = UITableViewCell(style: .Value1, reuseIdentifier: cellTitle)
				}
				cell?.textLabel?.text = cellTitle
				cell?.detailTextLabel?.text = "NO_LANGUAGE".localized
				cell?.accessoryType = .DisclosureIndicator
			}
		}
		
		if (indexPath.section == 1) {
			if (indexPath.row == 0) {
				if let learn = learnLanguage {
					cell?.detailTextLabel?.text = learn.1
				}
			} else if (indexPath.row == 1) {
				if let base = baseLanguage {
					cell?.detailTextLabel?.text = base.1
				}
			}
		}
		
		return cell!
	}
	
	func setupTextFields() {
		nameField.placeholder = "NAME".localized
		nameField.autocapitalizationType = .Words
		nameField.adjustsFontSizeToFitWidth = true
		
		emailField.placeholder = "EMAIL".localized
		emailField.keyboardType = .EmailAddress
		emailField.autocapitalizationType = .None
		emailField.adjustsFontSizeToFitWidth = true
		
		passwordField.placeholder = "PASSWORD".localized
		passwordField.secureTextEntry = true
	}
	
	func register(sender: UIBarButtonItem) {
		let name = nameField.text
		let email = emailField.text
		let password = passwordField.text
		
		if let na = name,  em = email, pw = password, base = baseLanguage?.0, learn = learnLanguage?.0 {
			ZeeguuAPI.sharedAPI().registerUserWithUsername(na, email: em, password: pw, completion: { (success) -> Void in
				if (success) {
					ZeeguuAPI.sharedAPI().setLearnedLanguage(learn, completion: { (success) -> Void in })
					ZeeguuAPI.sharedAPI().setNativeLanguage(base, completion: { (success) -> Void in })
					self.dismissViewControllerAnimated(true, completion: nil)
				} else {
					// TODO: pretty error message
					print("register error")
				}
			})
		} else {
			Utils.showOKAlertWithTitle("NO_LOGIN".localized, message: "NO_LOGIN_MESSAGE".localized, okAction: nil)
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if (indexPath.section == 1) {
			if (indexPath.row == 0) {
				self.navigationController?.pushViewController(LanguagesTableViewController(chooseType: .LearnLanguage, delegate: self), animated: true)
			} else if (indexPath.row == 1) {
				self.navigationController?.pushViewController(LanguagesTableViewController(chooseType: .BaseLanguage, delegate: self), animated: true)
			}
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	func didChooseLanguage(language: (String, String), languageType: LanguageChooseType) {
		switch (languageType) {
			case .BaseLanguage:
				baseLanguage = language
				break
			case .LearnLanguage:
				learnLanguage = language
				break
		}
		self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
	}
}


