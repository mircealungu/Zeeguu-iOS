//
//  UpdateTranslationViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 23-05-16.
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

protocol UpdateTranslationViewControllerDelegate {
	
	func updateTranslationViewControllerDidChangeTranslation(utvc: UpdateTranslationViewController, newTranslation: String, otherTranslations: [String: String]?)
	func updateTranslationViewControllerDidDeleteTranslation(utvc: UpdateTranslationViewController)
	
}

class UpdateTranslationViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
	
	let oldTranslation: String
	var otherTranslations: [String: String]?
	var delegate: UpdateTranslationViewControllerDelegate?
	
	private var data: [[(String, String)]]
	private var action: ZGJavaScriptAction
	
	private var deleteIndex: Int
	
	func dismiss(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	init(oldTranslation: String, action: ZGJavaScriptAction) {
		self.oldTranslation = oldTranslation
		self.action = action
		self.deleteIndex = 1
		let s2 = [("", "UPDATE_TRANSLATION".localized)]
		let s3 = [("", "DELETE_TRANSLATION".localized)]
		
		data = [s2, s3]
		super.init(style: .Grouped)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.beginRefreshing()
		
		self.modalPresentationStyle = .FormSheet
		
		self.title = "UPDATE_TRANSLATION".localized
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(UpdateTranslationViewController.dismiss(_:)))
		
		loadTranslations()
	}
	
	func loadTranslations() {
		if let dict = action.getActionInformation() {
			if let ot = dict["otherTranslations"] where !ot.isEmpty {
				self.otherTranslations = JSON.parse(ot).dictionaryObject as? [String: String]
				self.prepareTranslationList()
			} else if let word = dict["originalWord"] {
				ZeeguuAPI.sharedAPI().getTranslationsForWord(word, context: "Test context", url: "Test url", completion: { (translation) in
					if let ts = translation?["translations"].array {
						var d = [String: String]()
						for t in ts {
							if let key = t["likelihood"].float, value = t["translation"].string {
								d[String(key)] = value
							}
						}
						self.otherTranslations = d
						
						self.prepareTranslationList()
					} else {
						self.endRefreshing()
					}
				})
			} else {
				self.endRefreshing()
			}
		} else {
			self.endRefreshing()
		}
	}
	
	func prepareTranslationList() {
		var s1 = [(String, String)]()
		if let ot = otherTranslations where ot.count > 0 {
			for (key, value) in ot {
				s1.append((key, value))
			}
		}
		
		// $0 is a pair with the left operand and right operand
		// $0.0 is the left operand and is a pair of 2 strings
		// $0.1 is the right operand and is a pair of 2 strings
		// $0.0.0 is the left string of that pair and is the likelihood of the left operand
		// $0.1.0 is the left string of that pair and is the likelihood of the right operand
		s1.sortInPlace({ $0.0.0.lowercaseString > $0.1.0.lowercaseString })
		deleteIndex += 1
		data.insert(s1, atIndex: 1)
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
			self.endRefreshing()
		}
	}
	
	func endRefreshing() {
		// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
		// This enables us to attach a completion block to the animation, deleting it before the
		// animation is complete causes glitching.
		CATransaction.begin()
		CATransaction.setCompletionBlock({ () -> Void in
			self.refreshControl = nil
		})
		self.refreshControl?.endRefreshing()
		CATransaction.commit()
	}
	
	override func viewWillAppear(animated: Bool) {
		self.preferredContentSize = CGSizeMake(300, 1024)
		let rect = self.tableView.rectForSection(self.tableView.numberOfSections - 1)
		let h = CGRectGetMaxY(rect)
		self.preferredContentSize = CGSizeMake(300, h)
	}
	
	override func viewDidAppear(animated: Bool) {
		let h = self.tableView.contentSize.height
		self.preferredContentSize = CGSizeMake(300, h)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return data.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data[section].count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell")
		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
		}
		
		let subs = cell.contentView.subviews
		for v in subs {
			v.removeFromSuperview()
		}
		
		let sec = indexPath.section
		let row = indexPath.row
		cell.textLabel?.text = data[sec][row].1
		cell.accessoryType = .None
		cell.accessoryView = nil
		
		if sec == 0 {
			if row == 0 {
				cell.selectionStyle = .None
				cell.textLabel?.text = nil
				
				let tf = UITextField.autoLayoutCapable()
				tf.text = oldTranslation
				tf.textColor = UIColor(red:56.0/255.0, green:84.0/255.0, blue:135.0/255.0, alpha:1.0);
				tf.addTarget(self, action: #selector(UpdateTranslationViewController.updateTranslation(_:)), forControlEvents: .PrimaryActionTriggered)
				tf.autocapitalizationType = .None
				
				cell.contentView.addSubview(tf)
				
				let views = ["tf": tf]
				
				cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tf]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
				cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[tf]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
				
				
			}
		} else if sec == deleteIndex {
			if row == 0 {
				cell.textLabel?.textColor = UIColor.redColor()
			}
		} else if sec == 1 { // delete index may also be 1, so then this case is not treated. As long as there are no translations yet, this is intended. When the translations arrive, the deleteIndex is increased.
			let text = data[sec][row].1
			cell.textLabel?.textColor = UIColor.blackColor()
			if text == oldTranslation {
				cell.accessoryType = .Checkmark
			} else {
				cell.accessoryType = .None
			}
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let sec = indexPath.section
		let row = indexPath.row
		if sec == 0 {
			let text = data[sec][row].1
			updateTranslationWith(text)
			self.dismissViewControllerAnimated(true, completion: nil)
		} else if sec == 2 {
			deleteTranslation()
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return "EDIT_TRANSLATION".localized
		} else if section == deleteIndex {
			return "DELETE_TRANSLATION".localized
		} else if section == 1 {
			return "ALTERNATIVE_TRANSLATIONS".localized
		}
		return nil
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == deleteIndex {
			return "DELETE_TRANSLATION_FOOTER".localized
		}
		return nil
	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func updateTranslation(sender: UITextField) {
		sender.resignFirstResponder()
		if let text = sender.text {
			updateTranslationWith(text)
		}
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func updateTranslationWith(text: String) {
		if let del = delegate where text != oldTranslation {
			del.updateTranslationViewControllerDidChangeTranslation(self, newTranslation: text, otherTranslations: otherTranslations)
		}
	}
	
	func deleteTranslation() {
		if let del = delegate {
			del.updateTranslationViewControllerDidDeleteTranslation(self)
		}
	}
	
}
