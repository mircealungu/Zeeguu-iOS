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
	
	func updateTranslationViewControllerDidChangeTranslationTo(translation: String, otherTranslations: [String: String]?)
	
}

class UpdateTranslationViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
	
	let oldTranslation: String
	var otherTranslations: [String: String]?
	var delegate: UpdateTranslationViewControllerDelegate?
	
	private var data: [[String]]
	
	init(oldTranslation: String, action: ZGJavaScriptAction) {
		self.oldTranslation = oldTranslation
		
		var s1 = ["Translation 1", "Translation x", "Translation n-1"]
		let s2 = ["UPDATE_TRANSLATION".localized]
		
		data = [s1, s2]
		super.init(style: .Grouped)
		self.modalPresentationStyle = .Popover
		self.popoverPresentationController?.delegate = self
		
		
		
		if let dict = action.getActionInformation() {
			if let ot = dict["otherTranslations"] where !ot.isEmpty {
				self.otherTranslations = JSON.parse(ot).dictionaryObject as? [String: String]
			} else if let word = dict["originalWord"] {
				ZeeguuAPI.sharedAPI().getTranslationsForWord(word, context: "Test context", url: "Test url", completion: { (translation) in
					if let ts = translation?["translations"].array {
						var d = [String: String]()
						for t in ts {
							if let key = t["translation_id"].int, value = t["translation"].string {
								d[String(key)] = value
							}
						}
						self.otherTranslations = d
						
						
						if let ot = self.otherTranslations where ot.count > 0 {
							s1.removeAll()
							for (_, value) in ot {
								s1.append(value)
							}
						}
						
						self.data = [s1, s2]
						dispatch_sync(dispatch_get_main_queue(), {
							self.tableView.reloadData()
						})
					}
				})
			}
		}
		if let ot = otherTranslations where ot.count > 0 {
			s1.removeAll()
			for (_, value) in ot {
				s1.append(value)
			}
		}
		
		data = [s1, s2]
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.clearsSelectionOnViewWillAppear = false
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
		var cell = tableView.dequeueReusableCellWithIdentifier("cell")
		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
		}
		
		let sec = indexPath.section
		let row = indexPath.row
		cell?.textLabel?.text = data[sec][row]
		cell?.accessoryType = .None
		cell?.accessoryView = nil
		
		if sec == 0 {
			if data[sec][row] == oldTranslation {
				cell?.accessoryType = .Checkmark
			} else {
				cell?.accessoryType = .None
			}
		} else if sec == 1 {
			if row == 0 {
				cell?.selectionStyle = .None
				cell?.textLabel?.text = nil
				if let subs = cell?.contentView.subviews {
					for v in subs {
						v.removeFromSuperview()
					}
				}
				
				let tf = UITextField.autoLayoutCapable()
				tf.text = oldTranslation
				tf.textColor = UIColor(red:56.0/255.0, green:84.0/255.0, blue:135.0/255.0, alpha:1.0);
				tf.addTarget(self, action: #selector(UpdateTranslationViewController.updateTranslation(_:)), forControlEvents: .PrimaryActionTriggered)
				tf.autocapitalizationType = .None
//				tf.becomeFirstResponder()
				
				cell?.contentView.addSubview(tf)
				
				let views = ["tf": tf]
				
				cell?.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[tf]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
				cell?.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[tf]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

				
			}
		}
		
		return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let sec = indexPath.section
		let row = indexPath.row
		let text = data[sec][row]
		if let del = delegate where text != oldTranslation {
			del.updateTranslationViewControllerDidChangeTranslationTo(text, otherTranslations: otherTranslations)
		}
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "NEW_TRANSLATION".localized
		}
		return nil
	}
	
//	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//		
//	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func updateTranslation(sender: UITextField) {
		sender.resignFirstResponder()
		if let text = sender.text, del = delegate where text != oldTranslation {
			del.updateTranslationViewControllerDidChangeTranslationTo(text, otherTranslations: otherTranslations)
		}
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
