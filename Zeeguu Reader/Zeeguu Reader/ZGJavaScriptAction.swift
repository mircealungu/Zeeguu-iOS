//
//  ZGJavaScriptAction.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 05-05-16.
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

/**
Holds a JavaScript action to be executed.
*/
enum ZGJavaScriptAction {
	/// No action
	case None
	/// The translate action. The first value contains the word to be translated, the second value contains the (html) id of the word.
	///
	/// Use the `ZGJavaScriptAction.getJavaScriptExpression` method to retrieve a JavaScript expression that will insert the translation behind the original word.
	///
	/// **Important**: Before using `ZGJavaScriptAction.getJavaScriptExpression`, use `ZGJavaScriptAction.changeWord` to replace the word with its translation. Otherwise, the original word is inserted!
	case Translate(String, String)
	/// The edit translation action. The first value contains the translation to be edited, the second value contains the original word, the third value contains the (html) id of the word.
	///
	/// Use the `ZGJavaScriptAction.getJavaScriptExpression` method to retrieve a JavaScript expression that will update the translation behind the original word.
	///
	/// **Important**: Before using `ZGJavaScriptAction.getJavaScriptExpression`, use `ZGJavaScriptAction.changeWord` to replace the translation with the new (custom) translation. Otherwise, the translation will not be updated!
	case EditTranslation(String, String, String)
	
	static func parseMessage(dict: Dictionary<String, String>) -> ZGJavaScriptAction {
		if let action = dict["action"], id = dict["id"] {
			if action == "translate" {
				if let word = dict["word"] {
					return .Translate(word, id)
				}
			} else if action == "editTranslation" {
				if let old = dict["oldTranslation"], orig = dict["originalWord"] {
					return .EditTranslation(old, orig, id)
				}
			}
		}
		return .None
	}
	
	mutating func changeWord(newWord: String) {
		switch self {
		case let .Translate(_, id):
			self = .Translate(newWord, id)
		case let .EditTranslation(_, orig, id):
			self = .EditTranslation(newWord, orig, id)
		default:
			break // do nothing
		}
	}
	
	func getWord() -> String? {
		switch self {
		case let .Translate(word, _):
			return word
		case let .EditTranslation(word, _, _):
			return word
		default:
			return nil
		}
	}
	
	func getOriginalWord() -> String? {
		switch self {
		case let .EditTranslation(_, word, _):
			return word
		default:
			return nil
		}
	}
	
	func getJavaScriptExpression() -> String {
		switch self {
		case let .Translate(word, id):
			return "insertTranslationForID(\"\(word)\", \"\(id)\")"
		case let .EditTranslation(word, _, id):
			return "updateTranslationForID(\"\(word)\", \"\(id)\")"
		default:
			return ""
		}
	}
}
