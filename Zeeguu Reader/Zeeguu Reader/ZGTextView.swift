//
//  ZGTextView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
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

class ZGTextView: UITextView {

	var article: Article?
	var willInstantlyTranslate = true
	
	private var isTranslating = false
	
	convenience init(article: Article?) {
		self.init()
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
		self.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
	}
	
	func selectedText() -> String {
		if let r = self.selectedTextRange, t = self.textInRange(r) {
			return t
		}
		return ""
	}
	
	func selectedTextContext() -> String {
		return Utils.selectedTextContextForText(self.attributedText, selectedRange: self.selectedRange)
	}
	
	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		if action == "translate:" {
			if (willInstantlyTranslate) {
				translate(self)
				return false
			}
			return true
		}
		return false
	}
	
	private func isSelectionAlreadyTranslated() -> Bool {
		let range = self.selectedRange
		
		let attributes = self.attributedText.attributesAtIndex(range.location + range.length, effectiveRange: nil)
		print("attributes: \(attributes)")
		if let color = attributes[NSForegroundColorAttributeName] where color.isEqual(AppColor.getTranslationTextColor()) {
			self.selectedTextRange = nil
			return true
		}
		return false
	}
	
	func translate(sender: AnyObject?) {
		if (isTranslating) {
			return
		}
		isTranslating = true
		print("translate called for \(self.selectedText()) with context: \"\(self.selectedTextContext())\"")
		
		if isSelectionAlreadyTranslated() {
			return
		}
		
		if let art = article {
			ZeeguuAPI.sharedAPI().translateWord(self.selectedText(), title: art.title, context: self.selectedTextContext(), url: art.url) { (dict) -> Void in
				if let t = dict?["translation"].string {
					print("\"\(self.selectedText())\" translated to \"\(t)\"")
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						let range = self.selectedRange
						self.scrollEnabled = false
						
						self.textStorage.replaceCharactersInRange(NSMakeRange(range.location + range.length, 0), withAttributedString: NSMutableAttributedString(string: " (\(t))", attributes: [NSFontAttributeName: self.font!, NSForegroundColorAttributeName: AppColor.getTranslationTextColor()]))
						
						self.resignFirstResponder()
						self.scrollEnabled = true
					})
				} else {
					print("translating \"\(self.selectedText())\" went wrong")
				}
				self.isTranslating = false
			}
		}
	}
	
	func bookmark(sender: AnyObject?) {
		NSLog("bookmark called")
	}
	
	override func scrollRectToVisible(rect: CGRect, animated: Bool) {
		// do nothing
	}

}
