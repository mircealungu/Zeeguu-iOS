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

	var article: Article!
	
	convenience init(article: Article) {
		self.init()
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func selectedText() -> String {
//		return self.stringByEvaluatingJavaScriptFromString("window.getSelection().toString()")!
		return self.textInRange(self.selectedTextRange!)!
	}
	
	func selectedTextContext() -> String {
		return Utils.selectedTextContextForText(self.text, selectedRange: self.selectedRange)
	}
	
	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//		NSLog("can perform action asked: %@, for selected text: %@", NSStringFromSelector(action), self.selectedText())
		if action == "bookmark:" {
			translate(self)
			return true
		}
		return false
	}
	
	func translate(sender: AnyObject?) {
		print("translate called for \(self.selectedText()) with context: \"\(self.selectedTextContext())\"")
		ZeeguuAPI.sharedAPI().translateWord(self.selectedText(), title: article.title, context: self.selectedTextContext(), url: article.url) { (translation) -> Void in
			if let t = translation {
				print("\"\(self.selectedText())\" translated to \"\(t)\"")
				
//				dispatch_async(dispatch_get_main_queue(), { () -> Void in
//					let alert = UIAlertController(title: "Translation", message: "\"\(self.selectedText())\" translated to \"\(t)\"", preferredStyle: UIAlertControllerStyle.ActionSheet)
//					
//					let selectionRange = self.selectedTextRange;
//					let selectionStartRect = self.caretRectForPosition(selectionRange!.start);
//					let selectionEndRect = self.caretRectForPosition(selectionRange!.end);
//					
//					let rect = CGRectMake(selectionStartRect.origin.x, selectionStartRect.origin.y, selectionEndRect.origin.x + selectionEndRect.size.width - selectionStartRect.origin.x, selectionStartRect.size.height)
//					
//					print("rect: \(rect)")
//					
//					alert.popoverPresentationController?.sourceRect = rect
//					alert.popoverPresentationController?.sourceView = self
//					
//					alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
//						alert.dismissViewControllerAnimated(true, completion: nil)
//					}))
//					(UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
//				})
			} else {
				print("translating \"\(self.selectedText())\" went wrong")
			}
		}
	}
	
	func bookmark(sender: AnyObject?) {
		NSLog("bookmark called")
	}

}
