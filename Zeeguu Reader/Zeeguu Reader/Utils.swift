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
import WebKit
import AVFoundation
import Zeeguu_API_iOS

class Utils {
	
	static func showOKAlertWithTitle(title: String, message: String, okAction: ((UIAlertAction) -> Void)?) {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: okAction))
			
			UIViewController.currentViewController()?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	static func showBinaryAlertWithTitle(title: String, message: String, yesAction: ((UIAlertAction) -> Void)?, noAction: ((UIAlertAction) -> Void)? = nil) {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "YES".localized, style: .Default, handler: yesAction))
			alert.addAction(UIAlertAction(title: "NO".localized, style: .Cancel, handler: noAction))
			
			UIViewController.currentViewController()?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	/// Returns the context (sentence) in which the selected text (indicated with the selected range) exists.
	///
	/// - parameter text: The text in which some substring was selected.
	/// - parameter range: The range of the selected substring.
	/// - returns: The context (sentence) in which the selected substring exists.
	static func selectedTextContextForText(text: NSAttributedString, selectedRange range: NSRange) -> String {
		let str: NSString = text.string;
		let sentenceBegin = str.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, range.location), locale: nil)
		let sentenceEnd = str.rangeOfString(".", options: [], range: NSMakeRange(range.location, text.length - range.location), locale: nil)
		
		var begin = (sentenceBegin.location == NSNotFound ? 0 : sentenceBegin.location + 2)
		let end = (sentenceEnd.location == NSNotFound ? text.length : sentenceEnd.location + sentenceEnd.length) - begin
		if (str.characterAtIndex(begin) == "\n".characterAtIndex(0)) {
			begin += 1
		}
		
		let newRange = NSMakeRange(begin, end)
		let context: NSAttributedString = text.attributedSubstringFromRange(newRange)
		let contextStr: NSMutableString = NSMutableString(string: context.string)
		
		// context is the context that may contain other translations
		
		for var i in (0 ..< context.length).reverse() {
			let effectiveRange: NSRangePointer = nil
			let color = context.attribute(NSForegroundColorAttributeName, atIndex: i, effectiveRange: effectiveRange)
			
			if let c = color {
				if c.isEqual(AppColor.getTranslationTextColor()) {
					if effectiveRange != nil {
						let r = effectiveRange.move()
						contextStr.replaceCharactersInRange(r, withString: "")
						i = r.location + 1
					} else {
						contextStr.replaceCharactersInRange(NSMakeRange(i, 1), withString: "")
					}
					// if the text is light gray, it is a previous translation
					// if effectiveRange is not NULL (pointing to 0x0) remove the characters in
					// that range from contextStr (plain (mutable) string, without attributes like color)
					// update i and go on
					// if effectiveRange is the NULL pointer, just remove this single character that was light gray
					// check documenation of NSAttributedString attribute:atIndex:effectiveRange: for more info about effectiveRange
				}
			}
			
			
		}
		
		return String(contextStr)
	}
	
	static func addUserScriptToUserContentController(controller: WKUserContentController, js: String) {
		let script = WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
		controller.addUserScript(script)
	}
	
	static func addUserScriptToUserContentController(controller: WKUserContentController, jsFileName: String) {
		let jsFilePath = NSBundle.mainBundle().pathForResource(jsFileName, ofType: "js")
		if let jsf = jsFilePath, jsFile = try? String(contentsOfFile: jsf) {
			let script = WKUserScript(source: jsFile, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
			controller.addUserScript(script)
		}
	}
	
	static func addStyleSheetToUserContentController(controller: WKUserContentController, cssFileName: String) {
		let cssFilePath = NSBundle.mainBundle().pathForResource(cssFileName, ofType: "css")
		if let cssf = cssFilePath, cssFile = try? String(contentsOfFile: cssf) {
			let js = ["var style = document.createElement(\"style\");\n",
			"style.innerHTML = \"\(cssFile.stringByReplacingOccurrencesOfString("\n", withString: "\\n"))\";\n",
			"document.getElementsByTagName(\"head\")[0].appendChild(style);"].reduce("", combine: +);
			
			let script = WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
			controller.addUserScript(script)
		}
	}
	
	static func sendMonitoringStatusToServer(key: String, value: String, data: [String: AnyObject]? = nil) {
		// Call ZeeguuAPI endpoint that accepts arbitrary statistics 
		ZeeguuAPI.sharedAPI().uploadUserActivityData(key, value: value, extraData: data) { (success) in
			print("Sent statistics to server: {\(key): \(value), data: \(data)}, success: \(success)")
		}
	}
	
	static func pronounce(word word: String, inLanguage language: String?) {
		_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		_ = try? AVAudioSession.sharedInstance().setActive(true)
		
		let synthesizer = AVSpeechSynthesizer()
		
		let utterance = AVSpeechUtterance(string: word)
		utterance.voice = AVSpeechSynthesisVoice(language: language)
		
		synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
		synthesizer.speakUtterance(utterance)
		
		_ = try? AVAudioSession.sharedInstance().setActive(false)
		
		Utils.sendMonitoringStatusToServer("userPronouncesWord", value: "1")
	}
}
