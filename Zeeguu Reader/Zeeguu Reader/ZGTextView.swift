//
//  ZGTextView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
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
		let range = self.selectedRange
		
		let text: NSString = self.text
		
		let sentenceBegin = text.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, range.location), locale: nil)
		let sentenceEnd = text.rangeOfString(".", options: [], range: NSMakeRange(range.location, text.length - range.location), locale: nil)
		
		let begin = (sentenceBegin.location == NSNotFound ? 0 : sentenceBegin.location + 2)
		let end = (sentenceEnd.location == NSNotFound ? text.length : sentenceEnd.location + 1) - sentenceEnd.location
		
		let newRange = NSMakeRange(begin, end)
		
		let beginning = self.beginningOfDocument;
		let startPos = self.positionFromPosition(beginning, offset:newRange.location);
		let endPos = self.positionFromPosition(startPos!, offset:newRange.length);
		let textRange = self.textRangeFromPosition(startPos!, toPosition:endPos!);
		return self.textInRange(textRange!)!
	}
	
	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		NSLog("can perform action asked: %@, for selected text: %@", NSStringFromSelector(action), self.selectedText())
		if action == "translate:" || action == "bookmark:" {
			
			return true
		}
		return false
	}
	
	func translate(sender: AnyObject?) {
		NSLog("translate called")
		ZeeguuAPI.sharedAPI().translateWord(self.selectedText(), context: self.selectedTextContext(), url: article.url) { (translation) -> Void in
			if let t = translation {
				print("\"\(self.selectedText())\" translated to \"\(t)\"")
				
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					let alert = UIAlertController(title: "Translation", message: "\"\(self.selectedText())\" translated to \"\(t)\"", preferredStyle: UIAlertControllerStyle.ActionSheet)
					
					let selectionRange = self.selectedTextRange;
					let selectionStartRect = self.caretRectForPosition(selectionRange!.start);
					let selectionEndRect = self.caretRectForPosition(selectionRange!.end);
					
					let rect = CGRectMake(selectionStartRect.origin.x, selectionStartRect.origin.y, selectionEndRect.origin.x + selectionEndRect.size.width - selectionStartRect.origin.x, selectionStartRect.size.height)
					
					print("rect: \(rect)")
					
					alert.popoverPresentationController?.sourceRect = rect
					alert.popoverPresentationController?.sourceView = self
					
					alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
						alert.dismissViewControllerAnimated(true, completion: nil)
					}))
					(UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
				})
			} else {
				print("translating \"\(self.selectedText())\" went wrong")
			}
		}
	}
	
	func bookmark(sender: AnyObject?) {
		NSLog("bookmark called")
	}

}
