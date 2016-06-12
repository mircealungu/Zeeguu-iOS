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
		let s2 = [ArticleViewTranslationMode.Instant.getTitle(), ArticleViewTranslationMode.WordPair.getTitle(), ArticleViewTranslationMode.Sentence.getTitle()]
		let s3 = ["DISABLE_LINKS".localized, "INSERT_TRANSLATION_IN_TEXT".localized]
		
		data = [s1, s2, s3]
		self.parent = parent
		super.init(style: .Grouped)
		self.modalPresentationStyle = .Popover
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
				sw.addTarget(self, action: #selector(ArticleViewOptionsTableViewController.setInsertTranslationInText(_:)), forControlEvents: .ValueChanged)
				cell?.accessoryView = sw
				
				let def = NSUserDefaults.standardUserDefaults()
				
				sw.on = def.boolForKey(InsertTranslationInTextDefaultsKey)
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
		parent.webview.executeJavaScriptAction(action)
	}
	
	func setLinkState(sender: UISwitch) {
		self.parent.disableLinks = sender.on
	}
	
	func setInsertTranslationInText(sender: UISwitch) {
		let def = NSUserDefaults.standardUserDefaults()
		def.setBool(sender.on, forKey: InsertTranslationInTextDefaultsKey)
		def.synchronize()
		
		parent.webview.executeJavaScriptAction(ZGJavaScriptAction.SetInsertsTranslation(sender.on))
	}
}
