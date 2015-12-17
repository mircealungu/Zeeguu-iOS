//
//  Utils.swift
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

class Utils {
	
	static func showOKAlertWithTitle(title: String, message: String, okAction: ((UIAlertAction) -> Void)?) {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: okAction))
			
			UIViewController.currentViewController()?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	/// Returns the context (sentence) in which the selected text (indicated with the selected range) exists.
	///
	/// - parameter text: The text in which some substring was selected.
	/// - parameter range: The range of the selected substring.
	/// - returns: The context (sentence) in which the selected substring exists.
	static func selectedTextContextForText(text: NSString, selectedRange range: NSRange) -> String {
		print("range: \(range)")
		
		let sentenceBegin = text.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, range.location), locale: nil)
		let sentenceEnd = text.rangeOfString(".", options: [], range: NSMakeRange(range.location, text.length - range.location), locale: nil)
		print("sentenceBegin: \(sentenceBegin)")
		print("sentenceEnd: \(sentenceEnd)")
		
		var begin = (sentenceBegin.location == NSNotFound ? 0 : sentenceBegin.location + 2)
		let end = (sentenceEnd.location == NSNotFound ? text.length : sentenceEnd.location + sentenceEnd.length) - begin
		if (text.characterAtIndex(begin) == "\n".characterAtIndex(0)) {
			++begin
		}
		print("begin: \(begin)")
		print("end: \(end)")
		
		let newRange = NSMakeRange(begin, end)
		
		return text.substringWithRange(newRange)
	}
	
}
