//
//  Bookmark.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 03-01-16.
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

/// The `Bookmark` class represents a bookmark. It holds the `date`, `word`, `translation` and more about the bookmark.
public class Bookmark {
	
	// MARK: Properties -
	
	/// The id of this bookmark
	public var id: String
	
	/// The date of this bookmark
	public var date: NSDate
	
	/// The word that was translated
	public var word: String
	/// The language of `Bookmark.word`
	public var wordLanguage: String
	
	/// The translation(s) of `Bookmark.word`
	public var translation: [String]
	/// The language of `Bookmark.translation`
	public var translationLanguage: String
	
	/// The title of the article in which `Bookmark.word` was translated
	public var title: String
	/// The context in which `Bookmark.word` was translated
	public var context: String?
	/// The url of the article in which `Bookmark.word` was translated
	public var url: String
	
	// MARK: Constructors -
	
	/**
	Construct a new `Bookmark` object.
	
	- parameter id: The id of this bookmark
	- parameter title: The title of the article in which `word` was translated
	- parameter context: The context in which `word` was translated
	- parameter url: The url of the article in which `word` was translated
	- parameter bookmarkDate: The date of the bookmark
	- parameter word: The translated word
	- parameter wordLanguage: The language of `word`
	- parameter translation: The translation(s)
	- parameter translationLanguage: The language of `translation`
	*/
	public init(id: String, title: String, context: String? = nil, url: String, bookmarkDate: String, word: String, wordLanguage: String, translation: [String], translationLanguage: String) {
		self.id = id
		self.title = title
		self.context = context
		self.url = url
		
		self.word = word
		self.wordLanguage = wordLanguage
		
		self.translation = translation
		self.translationLanguage = translationLanguage
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "EN-US")
		formatter.dateFormat = "EEEE, dd MMMM y"

		let date = formatter.dateFromString(bookmarkDate)
		self.date = date!
	}
	
	/// Deletes this bookmark.
	///
	/// - parameter completion: A block that will receive a boolean indicating if the bookmark could be deleted or not.
	public func delete(completion: (success: Bool) -> Void) {
		ZeeguuAPI.sharedAPI().deleteBookmarkWithID(self.id) { (success) in
			completion(success: success)
		}
	}
	
	/// Adds a translation to this bookmark.
	///
	/// - parameter translation: The translation to add to this bookmark.
	/// - parameter completion: A block that will receive a boolean indicating if the translation could be added or not.
	public func addTranslation(translation: String, completion: (success: Bool) -> Void) {
		ZeeguuAPI.sharedAPI().addNewTranslationToBookmarkWithID(self.id, translation: translation) { (success) in
			completion(success: success)
		}
	}
	
	/// Deletes a translation from this bookmark.
	///
	/// - parameter translation: The translation to remove from this bookmark.
	/// - parameter completion: A block that will receive a boolean indicating if the translation could be deleted or not.
	public func deleteTranslation(translation: String, completion: (success: Bool) -> Void) {
		ZeeguuAPI.sharedAPI().deleteTranslationFromBookmarkWithID(self.id, translation: translation) { (success) in
			completion(success: success)
		}
	}
	
	/// Retrieves all translations for this bookmark.
	///
	/// - parameter completion: A block that will receive a dictionary with the translations.
	public func getTranslations(completion: (dict: JSON?) -> Void) {
		ZeeguuAPI.sharedAPI().getTranslationsForBookmarkWithID(self.id) { (dict) in
			completion(dict: dict)
		}
	}
	
}
