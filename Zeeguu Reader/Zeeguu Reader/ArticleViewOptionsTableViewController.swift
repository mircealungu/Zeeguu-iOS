//
//  ArticleViewOptionsTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 17-04-16.
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

class ArticleViewOptionsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
	
	private let parent: ArticleViewController
	private let data: [[String]]
	
	init(parent: ArticleViewController) {
		let s1 = ["FONTSIZE".localized]
		let s2 = ["INSTANT_TRANSLATION".localized, "TRANSLATE_WORD_PAIR".localized, "TRANSLATE_SENTENCE".localized]
		let s3 = ["DISABLE_LINKS".localized, "PRONOUNCE_TRANSLATED_WORD".localized]
		
		data = [s1, s2, s3]
		self.parent = parent
		super.init(style: .Grouped)
		self.modalPresentationStyle = .Popover
		self.popoverPresentationController?.delegate = self
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
		
		if sec == 0 && row == 0 {
			cell?.selectionStyle = .None
			let stepper = UIStepper()
			stepper.minimumValue = -5
			stepper.maximumValue = 10
			stepper.value = 0
			stepper.setIncrementImage(letterImageWithFontSize(20), forState: .Normal)
			stepper.setDecrementImage(letterImageWithFontSize(14), forState: .Normal)
			stepper.addTarget(self, action: #selector(ArticleViewOptionsTableViewController.changeFontSize(_:)), forControlEvents: .ValueChanged)
			cell?.accessoryView = stepper
		} else if sec == 1 {
			if (row == 0 && parent.translationMode == .Instant) || (row == 1 && parent.translationMode == .WordPair) || (row == 2 && parent.translationMode == .Sentence) {
				cell?.accessoryType = .Checkmark
			}
		} else if sec == 2 {
			if row == 0 {
				let sw = UISwitch()
				sw.addTarget(self, action: #selector(ArticleViewOptionsTableViewController.setLinkState(_:)), forControlEvents: .ValueChanged)
				cell?.accessoryView = sw
				sw.on = self.parent.disableLinks
			} else if row == 1 {
				let sw = UISwitch()
				sw.addTarget(self, action: #selector(ArticleViewOptionsTableViewController.setPronounceTranslatedWord(_:)), forControlEvents: .ValueChanged)
				cell?.accessoryView = sw
				sw.on = self.parent.pronounceTranslatedWord
			}
		}
		
        return cell!
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let sec = indexPath.section
		let row = indexPath.row
		if sec == 1 {
			if row == 0 {
				parent.translationMode = .Instant
			} else if row == 1 {
				parent.translationMode = .WordPair
			} else if row == 2 {
				parent.translationMode = .Sentence
			}
		}
		self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(1, 1)), withRowAnimation: .Automatic)
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 1 {
			return "TRANSLATION_MODE".localized
		}
		return nil
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 1 {
			return "TRANSLATION_MODE_DESCRIPTION".localized
		}
		return nil
	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func letterImageWithFontSize(fontSize: CGFloat) -> UIImage {
		let letter: NSString = "A"
		let size = letter.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		letter.drawAtPoint(CGPointZero, withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(fontSize), NSForegroundColorAttributeName: UIColor.blackColor()])
		let im = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return im
	}
	
	func changeFontSize(sender: UIStepper) {
		let action = ZGJavaScriptAction.ChangeFontSize(Int(sender.value))
		parent.webview.evaluateJavaScript(action.getJavaScriptExpression()) { (result, error) in
			print("result: \(result)")
			print("error: \(error)")
		}
	}
	
	func setLinkState(sender: UISwitch) {
		self.parent.disableLinks = sender.on
	}
	
	func setPronounceTranslatedWord(sender: UISwitch) {
		self.parent.pronounceTranslatedWord = sender.on
	}
}
