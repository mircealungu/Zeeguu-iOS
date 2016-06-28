//
//  StringExtension.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 12-12-15.
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
import AVFoundation

extension String {
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
	
	func localizedWithComment(comment: String) -> String {
		return NSLocalizedString(self, comment: comment)
	}
	
	func insert(string:String,ind:Int) -> String {
		return String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count - ind))
	}
	
	/// This method will escape slashes and double quotes. This enables you to insert this string into
	/// a JavaScript function as a JavaScript string.
	mutating func JSEscape() {
		self = self.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
		self = self.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
		self = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
	/// This method will escape slashes and double quotes. This enables you to insert this string into
	/// a JavaScript function as a JavaScript string.
	func stringByJSEscaping() -> String {
		var s = self.stringByReplacingOccurrencesOfString("\\", withString: "\\\\")
		s = s.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
		s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		return s
	}
	
	func pronounce(inLanguage language: String?) {
		_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		_ = try? AVAudioSession.sharedInstance().setActive(true)
		
		let synthesizer = AVSpeechSynthesizer()
		
		let utterance = AVSpeechUtterance(string: self)
		utterance.voice = AVSpeechSynthesisVoice(language: language)
		
		synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
		synthesizer.speakUtterance(utterance)
		
		_ = try? AVAudioSession.sharedInstance().setActive(false)
		
		ZeeguuAPI.sendMonitoringStatusToServer("userPronouncesWord", value: "1")
	}
}