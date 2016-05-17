//
//  ZGWebView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-05-16.
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
import Zeeguu_API_iOS

class ZGWebView: WKWebView {
	
	var article: Article?
	var willInstantlyTranslate: Bool
	let coverView: UIView
	
	private var isTranslating = false
	
	init(article: Article?, webViewConfiguration: WKWebViewConfiguration? = nil) {
		self.willInstantlyTranslate = true
		self.coverView = UIView.autoLayoutCapable()
		if let wvc = webViewConfiguration {
			super.init(frame: CGRectZero, configuration: wvc)
		} else {
			super.init()
		}
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
		self.coverView.userInteractionEnabled = false
	}
	
//	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
//		let bool = super.canPerformAction(action, withSender: sender)
//		print("webview bool: \(bool)")
//		return bool
//		
//		print("webview canPerformAction: \(action)")
////		if action == #selector(ZGTextView.translate(_:)) {
////			if (willInstantlyTranslate) {
////				translate(self)
////				return false
////			}
////			return true
////		}
//		return false
//	}
	
	func translate(sender: AnyObject?) {
		if isTranslating {
			return
		}
		isTranslating = true
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.addSubview(self.coverView)
			self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v": self.coverView]))
			self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v": self.coverView]))
		})
		
		
		self.evaluateJavaScript("getSelectedText()") { (result, error) in
			print("result: \(result)")
			print("error: \(error)")
			
			if let result = result as? String, art = self.article {
				
				ZeeguuAPI.sharedAPI().translateWord(result, title: art.title, context: "No context yet", url: art.url) { (dict) -> Void in
					if let t = dict?["translation"].string {
						print("\"\(result)\" translated to \"\(t)\"")
						
						let html = "<span style=\"color: red;\"> \(t)</span>".stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
						print("html: \(html)")
						let script = "insertHtmlAfterSelection(\"\(html)\");"
						print("script: \(script)")
						self.evaluateJavaScript(script, completionHandler: { (result, error) in
							print("result: \(result)")
							print("error: \(error)")
						})
						
//						dispatch_async(dispatch_get_main_queue(), { () -> Void in
//							let range = self.selectedRange
//							self.scrollEnabled = false
//							
//							self.textStorage.replaceCharactersInRange(NSMakeRange(range.location + range.length, 0), withAttributedString: NSMutableAttributedString(string: " (\(t))", attributes: [NSFontAttributeName: self.font!, NSForegroundColorAttributeName: AppColor.getTranslationTextColor()]))
//							
//							self.resignFirstResponder()
//							self.scrollEnabled = true
//							
//							let synthesizer = AVSpeechSynthesizer()
//							
//							let utterance = AVSpeechUtterance(string: self.selectedText())
//							utterance.voice = AVSpeechSynthesisVoice(language: self.article?.feed.language)
//							
//							synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
//							synthesizer.speakUtterance(utterance)
//						})
					} else {
						print("translating \"\(result)\" went wrong")
					}
					self.isTranslating = false
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						self.coverView.removeFromSuperview()
					})
				}
				
				
			}
			
//			print("translate called for \(self.selectedText()) with context: \"\(self.selectedTextContext())\"")
		}
		
		
		
//		if isSelectionAlreadyTranslated() {
//			return
//		}
//
//		if let art = article {
//			ZeeguuAPI.sharedAPI().translateWord(self.selectedText(), title: art.title, context: self.selectedTextContext(), url: art.url) { (dict) -> Void in
//				if let t = dict?["translation"].string {
//					print("\"\(self.selectedText())\" translated to \"\(t)\"")
//					
//					dispatch_async(dispatch_get_main_queue(), { () -> Void in
//						let range = self.selectedRange
//						self.scrollEnabled = false
//						
//						self.textStorage.replaceCharactersInRange(NSMakeRange(range.location + range.length, 0), withAttributedString: NSMutableAttributedString(string: " (\(t))", attributes: [NSFontAttributeName: self.font!, NSForegroundColorAttributeName: AppColor.getTranslationTextColor()]))
//						
//						self.resignFirstResponder()
//						self.scrollEnabled = true
//						
//						let synthesizer = AVSpeechSynthesizer()
//						
//						let utterance = AVSpeechUtterance(string: self.selectedText())
//						utterance.voice = AVSpeechSynthesisVoice(language: self.article?.feed.language)
//						
//						synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
//						synthesizer.speakUtterance(utterance)
//					})
//				} else {
//					print("translating \"\(self.selectedText())\" went wrong")
//				}
//				self.isTranslating = false
//			}
//		}
	}
	
}