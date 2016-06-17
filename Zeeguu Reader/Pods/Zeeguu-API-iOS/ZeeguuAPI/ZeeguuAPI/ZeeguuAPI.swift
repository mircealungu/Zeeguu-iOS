//
//  ZeeguuAPI.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 28-11-15.
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

/// This class is a gateway to the Zeeguu API. You can use the instance of this class obtained by `ZeeguuAPI.sharedAPI()` to communicate with the Zeeguu API.
public class ZeeguuAPI {
	
	// MARK: Properties -
	
	private static let instance = ZeeguuAPI()
	
	/// Whether to enable debug output. Set this to `true` to see debug output and find out why an endpoint is not returning what you expect.
	public var enableDebugOutput = false
	
	var currentSessionID: Int {
		didSet {
			let def = NSUserDefaults.standardUserDefaults()
			def.setObject(currentSessionID, forKey: ZeeguuAPI.sessionIDKey)
		}
	}
	
	/// Check if a user is logged in.
	///
	/// - returns: `true` if a user is logged in, `false` otherwise.
	public var isLoggedIn: Bool {
		get {
			return currentSessionID != 0
		}
	}
	
	// MARK: Static methods -
	
	/// Get the `ZeeguuAPI` instance. This method is the only way to get an instance of the ZeeguuAPI class.
	///
	/// - returns: The shared `ZeeguuAPI` instance.
	public static func sharedAPI() -> ZeeguuAPI {
		return instance;
	}
	
	private init() {
		self.currentSessionID = 0
		let def = NSUserDefaults.standardUserDefaults()
		if (def.objectForKey(ZeeguuAPI.sessionIDKey) != nil) {
			self.currentSessionID = def.objectForKey(ZeeguuAPI.sessionIDKey)!.integerValue
		}
	}
	
	// MARK: Methods -
	
	// MARK: User operations
	
	/// Registers a user.
	///
	/// After the user is registered and logged in, you can use the ZeeguuAPI object to make requests on behalf of the user.
	///
	/// - parameter username: The username of the user to register.
	/// - parameter email: The email address of the user.
	/// - parameter password: The password of the user.
	/// - parameter completion: A block that receives a success parameter, which is true if the user was logged in successfully.
	public func registerUserWithUsername(username: String, email: String, password: String, completion: (success: Bool) -> Void) {
		let request = self.requestWithEndPoint(.AddUser, pathComponents: [email], method: .POST, parameters: ["username":username, "password":password])
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			if (response != nil) {
				let sesID = Int(response!)
				if (sesID != nil) {
					self.currentSessionID = sesID!
				}
				completion(success: true)
			} else {
				completion(success: false)
			}
		}
	}
	
	/// Logs a user in.
	///
	/// After the user is logged in, you can use the ZeeguuAPI object to make requests on behalf of the user.
	///
	/// - parameter email: The email address of the user to log in.
	/// - parameter password: The password of the user.
	/// - parameter completion: A block that receives a success parameter, which is true if the user was logged in successfully.
	public func loginWithEmail(email: String, password: String, completion: (success: Bool) -> Void) {
		let request = self.requestWithEndPoint(.Session, pathComponents: [email], method: .POST, parameters: ["password":password])
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			if (response != nil) {
				let sesID = Int(response!)
				if (sesID != nil) {
					self.currentSessionID = sesID!
				}
				completion(success: true)
			} else {
				completion(success: false)
			}
		}
	}
	
	/// Retrieves the details of the user.
	///
	/// - parameter completion: A block that will receive a `JSON` object, which contains the list of bookmarks.
	public func getUserDetails(completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.getUserDetails, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Logs the current user out.
	///
	/// After the user is logged out, you cannot use the ZeeguuAPI object anymore to make requests, until a user logs in again.
	/// - parameter force: Force logout. Set this to `true` if the server is not able to complete logout and you want to get rid of the session id.
	/// - parameter completion: A block that will receive a boolean indicating if the logout was a success.
	public func logout(force force: Bool = false, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.Logout, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: { (success) -> Void in
				if (success || force) {
					self.currentSessionID = 0
				}
				completion(success: success);
			})
		}
	}
	
	/// Retrieves the language code of the learned langugage of the logged in user.
	///
	/// - parameter completion: A block that will receive a language code of the learned language or nil if the request couldn't be completed.
	public func getLearnedLanguage(completion: (langCode: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(langCode: nil)
		}
		let request = self.requestWithEndPoint(.LearnedLanguage, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Sets the language code of the learned langugage of the logged in user.
	///
	/// - parameter newLanguageCode: The language code of the language that will be the new learned language.
	/// - parameter completion: A block that will receive a boolean indication if the request succeeded.
	public func setLearnedLanguage(newLanguageCode: String, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.LearnedLanguage, pathComponents: [newLanguageCode], method: .POST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion);
		}
	}
	
	/// Retrieves the language code of the native langugage of the logged in user.
	///
	/// - parameter completion: A block that will receive a language code of the native language or nil if the request couldn't be completed.
	public func getNativeLanguage(completion: (langCode: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(langCode: nil)
		}
		let request = self.requestWithEndPoint(.NativeLanguage, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Sets the language code of the native langugage of the logged in user.
	///
	/// - parameter newLanguageCode: The language code of the language that will be the new native language.
	/// - parameter completion: A block that will receive a boolean indication if the request succeeded.
	public func setNativeLanguage(newLanguageCode: String, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.NativeLanguage, pathComponents: [newLanguageCode], method: .POST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion);
		}
	}
	
	/// Retrieves the language code of the learned and native langugage of the logged in user.
	///
	/// - parameter completion: A block that will receive a `JSON` object, which contains the dictornary with language codes of the learned and native language.
	public func getLearnedAndNativeLanguage(completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.LearnedAndNativeLanguage, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	// MARK: Zeeguu API Languages
	
	/// Retrieves the language codes of all available languages that the Zeeguu API supports as a learning language.
	///
	/// - parameter completion: A block that will receive a `JSON` object, which contains the array with the language codes.
	public func getAvailableLanguages(completion: (array: JSON?) -> Void) {
		let request = self.requestWithEndPoint(.AvailableLanguages, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the language codes of all available languages that the Zeeguu API supports as a native language.
	///
	/// - parameter completion: A block that will receive a `JSON` object, which contains the array with the language codes.
	public func getAvailableNativeLanguages(completion: (array: JSON?) -> Void) {
		let request = self.requestWithEndPoint(.AvailableNativeLanguages, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	// MARK: Bookmark operations
	
	/// Retrieves the bookmarks of the user, organized by date.
	///
	/// - parameter withContext: If `withContext` is `true`, the text where a bookmark was found is also returned. If `false`, only the bookmark (without context) is returned.
	/// - parameter completion: A block that will receive a `JSON` object, which contains the list of bookmarks.
	public func getBookmarksByDayWithContext(withContext: Bool, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		var pathComponents: Array<String>
		if (withContext) {
			pathComponents = ["with_context"]
		} else {
			pathComponents = ["without_context"]
		}
		let request = self.requestWithEndPoint(.BookmarksByDay, pathComponents: pathComponents, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the bookmarks of the user, organized by date.
	///
	/// - parameter withContext: If `withContext` is `true`, the text where a bookmark was found is also returned. If `false`, only the bookmark (without context) is returned.
	/// - parameter afterDate: the date after which to start retrieving the bookmarks. if no date is specified, all the bookmarks are returned.
	/// - parameter completion: A block that will receive a `JSON` object, which contains the list of bookmarks.
	public func getBookmarksByDayWithContext(withContext: Bool, afterDate: NSDate, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		
		var paramsPOST = Dictionary<String, String>()
		paramsPOST["with_context"] = String(withContext)
		
		let formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "GMT")
		formatter.dateFormat = "y-MM-dd'T'HH:mm:ss"
		paramsPOST["after_date"] = formatter.stringFromDate(afterDate)
		
		let request = self.requestWithEndPoint(.BookmarksByDay, method: .POST, parameters: paramsPOST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Adds the translation of the given word to the user's bookmarks and Retrieves its ID.
	///
	/// - parameter word: The word to bookmark.
	/// - parameter translation: The translation of `word`.
	/// - parameter context: The context in which the word appeared.
	/// - parameter url: The url of the article in which the word was found.
	/// - parameter title: The title of the article in which the word was found.
	/// - parameter completion: A block that will receive a string containing the id of the newly made bookmark.
	public func bookmarkWord(word: String, translation: String, context: String, url: String, title: String?, completion: (bookmarkID: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(bookmarkID: nil)
		}
		
		self.getLearnedAndNativeLanguage { (dict) -> Void in
			if (dict != nil) {
				if let learned = dict!["learned"].string, native = dict!["native"].string {
					var params = ["context": context, "url": url]
					if (title != nil) {
						params["title"] = title
					}
					let request = self.requestWithEndPoint(.BookmarkWithContext, pathComponents: [learned, word, native, translation], method: .POST, parameters: params)
					self.sendAsynchronousRequest(request) { (response, error) -> Void in
						self.checkStringResponse(response, error: error, completion: completion)
					}
				}
			} else {
				completion(bookmarkID: nil)
			}
		}
	}
	
	/// Deletes the bookmark with the given ID.
	///
	/// - parameter bookmarkID: The ID of the bookmark to delete.
	/// - parameter completion: A block that will receive a boolean indicating if the bookmark could be deleted or not.
	public func deleteBookmarkWithID(bookmarkID: String, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.DeleteBookmark, pathComponents: [bookmarkID], method: .POST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion);
		}
	}
	
	/// Retrieves the exercise log of the user for a given bookmark.
	///
	/// - parameter bookmarkID: The ID of the bookmark for which to get the exercise log.
	/// - parameter completion: A block that will receive a `JSON` object, which contains the exercise log.
	public func getExerciseLogWithBookmarkID(bookmarkID: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetExerciseLogForBookmark, pathComponents: [bookmarkID], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Adds a translation to the bookmark with the given ID.
	///
	/// - parameter bookmarkID: The ID of the bookmark.
	/// - parameter translation: The translation to add to the bookmark.
	/// - parameter completion: A block that will receive a boolean indicating if the translation could be added or not.
	public func addNewTranslationToBookmarkWithID(bookmarkID: String, translation: String, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.AddNewTranslationToBookmark, pathComponents: [translation, bookmarkID], method: .POST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion);
		}
	}
	
	/// Deletes a translation from the bookmark with the given ID.
	///
	/// - parameter bookmarkID: The ID of the bookmark.
	/// - parameter translation: The translation to remove from the bookmark.
	/// - parameter completion: A block that will receive a boolean indicating if the translation could be deleted or not.
	public func deleteTranslationFromBookmarkWithID(bookmarkID: String, translation: String, completion: (success: Bool) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(success: false)
		}
		let request = self.requestWithEndPoint(.DeleteTranslationFromBookmark, pathComponents: [bookmarkID, translation], method: .POST)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion);
		}
	}
	
	/// Retrieves all translations for the bookmark with the given ID.
	///
	/// - parameter bookmarkID: The ID of the bookmark.
	/// - parameter completion: A block that will receive a dictionary with the translations.
	public func getTranslationsForBookmarkWithID(bookmarkID: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetTranslationsForBookmark, pathComponents: [bookmarkID], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves all learned bookmarks for the current user.
	///
	/// - parameter langCode: The language code for which to retrieve the bookmarks.
	/// - parameter completion: A block that will receive a dictionary with the bookmarks.
	public func getLearnedBookmarksWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetLearnedBookmarks, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	// MARK: Words operations
	
	/// Retrieves the words that the user is currently studying.
	///
	/// - parameter completion: A block that will receive a `JSON` object, which contains the list of words.
	public func getStudyingWords(completion: (array: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(array: nil)
		}
		let request = self.requestWithEndPoint(.UserWords, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves all not looked up words for the current user.
	///
	/// - parameter langCode: The language code for which to retrieve the words.
	/// - parameter completion: A block that will receive a dictionary with the words.
	public func getNotLookedUpWordsWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetNotLookedUpWords, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves all words that have not been encountered yet by the current user.
	///
	/// - parameter langCode: The language code for which to retrieve the words.
	/// - parameter completion: A block that will receive a dictionary with the words.
	public func getNotEncounteredWordsWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetNotEncounteredWords, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves all known bookmarks for the current user.
	///
	/// - parameter langCode: The language code for which to retrieve the bookmarks.
	/// - parameter completion: A block that will receive a dictionary with the bookmarks.
	public func getKnownBookmarksWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetKnownBookmarks, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves all known words for the current user.
	///
	/// - parameter langCode: The language code for which to retrieve the words.
	/// - parameter completion: A block that will receive a dictionary with the words.
	public func getKnownWordsWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetKnownWords, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves words that the current user probably knows.
	///
	/// - parameter langCode: The language code for which to retrieve the words.
	/// - parameter completion: A block that will receive a dictionary with the words.
	public func getProbablyKnownWordsWithLangCode(langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		let request = self.requestWithEndPoint(.GetProbablyKnownWords, pathComponents: [langCode], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	// MARK: Translation
	
	/// Retrieves the translation of the given word from the user's learned language to the user's native language.
	///
	/// - parameter word: The word to translate.
	/// - parameter title: The title of the article in which the word was translated.
	/// - parameter context: The context in which the word appeared.
	/// - parameter url: The url of the article in which the word was translated.
	/// - parameter completion: A block that will receive a dictionary containing the translation of `word`.
	public func translateWord(word: String, title: String, context: String, url: String, completion: (translation: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(translation: nil)
		}
		
		self.getLearnedAndNativeLanguage { (dict) -> Void in
			if (dict != nil) {
				if let learned = dict!["learned"].string, native = dict!["native"].string {
					let request = self.requestWithEndPoint(.TranslateAndBookmark, pathComponents: [learned, native], method: .POST, parameters: ["title": title, "context": context, "word": word, "url": url])
					self.sendAsynchronousRequest(request) { (response, error) -> Void in
						self.checkJSONResponse(response, error: error, completion: completion)
					}
				} else  {
					completion(translation: nil)
				}
			} else {
				completion(translation: nil)
			}
			
		}
	}
	
	/// Retrieves multiple possible translations of the given word from the user's learned language to the user's native language.
	///
	/// - parameter word: The word to translate.
	/// - parameter context: The context in which the word appeared.
	/// - parameter url: The url of the article in which the word was translated.
	/// - parameter completion: A block that will receive a dictionary containing the translation of `word`.
	public func getTranslationsForWord(word: String, context: String, url: String, completion: (translation: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(translation: nil)
		}
		
		self.getLearnedAndNativeLanguage { (dict) -> Void in
			if (dict != nil) {
				if let learned = dict!["learned"].string, native = dict!["native"].string {
					let request = self.requestWithEndPoint(.GetPossibleTranslations, pathComponents: [learned, native], method: .POST, parameters: ["context": context, "word": word, "url": url])
					self.sendAsynchronousRequest(request) { (response, error) -> Void in
						self.checkJSONResponse(response, error: error, completion: completion)
					}
				} else  {
					completion(translation: nil)
				}
			} else {
				completion(translation: nil)
			}
			
		}
	}
	
	// MARK: Statistics
	
	/// Retrieves the lower bound percentage of basic vocabulary.
	///
	/// - parameter completion: A block that will receive a string with the percentage.
	public func getLowerBoundPercentageOfBasicVocabularyWithCompletion(completion: (percentage: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(percentage: nil)
		}
		let request = self.requestWithEndPoint(.GetLowerBoundPercentageOfBasicVocabulary, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the upper bound percentage of basic vocabulary.
	///
	/// - parameter completion: A block that will receive a string with the percentage.
	public func getUpperBoundPercentageOfBasicVocabularyWithCompletion(completion: (percentage: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(percentage: nil)
		}
		let request = self.requestWithEndPoint(.GetUpperBoundPercentageOfBasicVocabulary, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the lower bound percentage of extended vocabulary.
	///
	/// - parameter completion: A block that will receive a string with the percentage.
	public func getLowerBoundPercentageOfExtendedVocabularyWithCompletion(completion: (percentage: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(percentage: nil)
		}
		let request = self.requestWithEndPoint(.GetLowerBoundPercentageOfExtendedVocabulary, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the upper bound percentage of extended vocabulary.
	///
	/// - parameter completion: A block that will receive a string with the percentage.
	public func getUpperBoundPercentageOfExtendedVocabularyWithCompletion(completion: (percentage: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(percentage: nil)
		}
		let request = self.requestWithEndPoint(.GetUpperBoundPercentageOfExtendedVocabulary, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the percentage of pobably known bookmarked words.
	///
	/// - parameter completion: A block that will receive a string with the percentage.
	public func getPercentageOfProbablyKnownBookmarkedWordsWithCompletion(completion: (percentage: String?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(percentage: nil)
		}
		let request = self.requestWithEndPoint(.GetPercentageOfProbablyKnownBookmarkedWords, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkStringResponse(response, error: error, completion: completion)
		}
	}
	
	// MARK: Content operations
	
	/// Retrieves the difficulties for the texts supplied.
	///
	/// - parameter texts: The texts to calculate the difficulties for.
	/// - parameter langCode: The language code the language in which the texts are written.
	/// - parameter personalized: Calculate difficulty score specific for the current user.
	/// - parameter rankBoundary: Upper boundary for word frequency rank (1-10000)
	/// - parameter completion: A block that will receive an array with the difficulties.
	public func getDifficultyForTexts(texts: Array<String>, langCode: String, difficultyComputer: String = "default", completion: (difficulties: [ArticleDifficulty]?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(difficulties: nil)
		}
		var newTexts: [Dictionary<String, String>] = []
		var counter = 0
		for text in texts {
			counter += 1
			newTexts.append(["content": text, "id": String(counter)])
		}
		
		let jsonDict = ["texts": newTexts, "difficulty_computer": difficultyComputer]
		
		let request = self.requestWithEndPoint(.GetDifficultyForText, pathComponents: [langCode], method: .POST, jsonBody: JSON(jsonDict))
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: { (dict) in
				if var array = dict?["difficulties"].array {
					array.sortInPlace({ (lhs, rhs) -> Bool in
						if let l = lhs["id"].string, r = rhs["id"].string {
							return Int(l) < Int(r)
						}
						return false
					})
					
					// The following piece of code loops over texts and tries to find the corresponding
					// difficulty in array. As array is sorted, if we don't find it, our current index (i) is
					// still lower than 'id' of the first difficulty in array. if we don't find difficulty, we insert
					// .Unknown string in the difficulties array
					var difficulties = [ArticleDifficulty]()
					var arrayIndex = 0
					for i in 0 ..< texts.count {
						let textIndex = i + 1
						if let idxStr = (arrayIndex < array.count ? array[arrayIndex]["id"].string : nil), idx = Int(idxStr), diff = array[i]["estimated_difficulty"].string, difficulty = ArticleDifficulty(rawValue: diff) where idx == textIndex {
							difficulties.append(difficulty)
							arrayIndex += 1
						} else {
							difficulties.append(.Unknown)
						}
					}
					completion(difficulties: difficulties)
				} else {
					completion(difficulties: nil)
				}
			})
		}
	}
	
	/// Retrieves the learnabilities for the texts supplied.
	///
	/// - parameter texts: The texts to calculate the learnabilities for.
	/// - parameter langCode: The language code the language in which the texts are written.
	/// - parameter completion: A block that will receive an array with the difficulties.
	public func getLearnabilityForTexts(texts: Array<String>, langCode: String, completion: (dict: JSON?) -> Void) {
		if (!self.checkIfLoggedIn()) {
			return completion(dict: nil)
		}
		var newTexts: [Dictionary<String, String>] = []
		var counter = 0
		for text in texts {
			counter += 1
			newTexts.append(["content": text, "id": String(counter)])
		}
		
		let jsonDict = ["texts": newTexts]
		
		let request = self.requestWithEndPoint(.GetLearnabilityForText, pathComponents: [langCode], method: .POST, jsonBody: JSON(jsonDict))
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves the content and an image from the given urls.
	///
	/// - parameter urls: The urls to get the content from.
	/// - parameter langCode: If not `nil`, the difficulty is calculated for all the contents.
	/// - parameter maxTimeout: Maximal time in seconds to wait for the results.
	/// - parameter completion: A block that will receive an array with the pairs (contents, image) of the urls.
	public func getContentFromURLs(urls: Array<String>, langCode: String? = nil, maxTimeout: Int = 10, completion: (contents: [(String, String, ArticleDifficulty)]?) -> Void) {
		var newURLs: [Dictionary<String, String>] = []
		var counter = 0
		for url in urls {
			counter += 1
			newURLs.append(["url": url, "id": String(counter)])
		}
		
		var jsonDict: Dictionary<String, AnyObject> = ["urls": newURLs, "timeout": String(maxTimeout)]
		if let lc = langCode {
			jsonDict["lang_code"] = lc
		}
		
		let request = self.requestWithEndPoint(.GetContentFromURL, method: .POST, jsonBody: JSON(jsonDict))
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkJSONResponse(response, error: error, completion: { (dict) in
				if var array = dict?["contents"].array {
					array.sortInPlace({ (lhs, rhs) -> Bool in
						if let l = lhs["id"].string, r = rhs["id"].string {
							return Int(l) < Int(r)
						}
						return false
					})
					
					// The following piece of code loops over newURLs and tries to find the corresponding
					// content in array. As array is sorted, if we don't find it, our current index (i) is
					// still lower than 'id' of the first content in array. if we don't find content, we insert
					// an empty string in the contents array
					var contents = [(String, String, ArticleDifficulty)]()
					var arrayIndex = 0
					for i in 0 ..< newURLs.count {
						let urlIndex = i + 1
						
						if let idxStr = (arrayIndex < array.count ? array[arrayIndex]["id"].string : nil), idx = Int(idxStr), content = array[arrayIndex]["content"].string, image = array[arrayIndex]["image"].string where idx == urlIndex {
							if let difficulty = array[arrayIndex]["difficulty"]["estimated_difficulty"].string, diff = ArticleDifficulty(rawValue: difficulty) {
								contents.append((content, image, diff))
							} else {
								contents.append((content, image, .Unknown))
							}
							arrayIndex += 1
						} else {
							contents.append(("", "", .Unknown))
						}
					}
					completion(contents: contents)
				} else {
					completion(contents: nil)
				}
			})
		}
	}
	
	// MARK: Feed operations
	
	/// Retrieves all feeds that were found at the given url.
	///
	/// - parameter url: The url for which to find the feeds.
	/// - parameter completion: A block that will receive an array with the feeds.
	public func getFeedsAtUrl(url: String, completion: (feeds: [Feed]?) -> Void) {
		let params = ["url": url]
		let request = self.requestWithEndPoint(.GetFeedsAtURL, method: .POST, parameters: params)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			if let res = response {
				let json = JSON.parse(res)
				var feeds = [Feed]()
				
				for (_, value):(String, JSON) in json {
					if let title = value["title"].string, url = value["url"].string, description = value["description"].string, language = value["language"].string {
						if let imageURL = value["image_url"]["href"].string {
							feeds.append(Feed(title: title, url: url, description: description, language: language, imageURL: imageURL))
						} else {
							feeds.append(Feed(title: title, url: url, description: description, language: language, imageURL: ""))
						}
					}
				}
				completion(feeds: feeds)
			} else {
				completion(feeds: nil)
			}
		}
	}
	
	/// Retrieves all feeds that are being followed by the current user.
	///
	/// - parameter completion: A block that will receive an array with the feeds.
	public func getFeedsBeingFollowed(completion: (feeds: [Feed]?) -> Void) {
		let request = self.requestWithEndPoint(.GetFeedsBeingFollowed, method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			if let res = response {
				let json = JSON.parse(res)
				var feeds = [Feed]()
				
				for (_, value):(String, JSON) in json {
					if let id = value["id"].int?.description, title = value["title"].string, url = value["url"].string, description = value["description"].string, language = value["language"].string, imageURL = value["image_url"].string {
						feeds.append(Feed(id: id, title: title, url: url, description: description, language: language, imageURL: imageURL))
					}
				}
				completion(feeds: feeds)
			} else {
				completion(feeds: nil)
			}
		}
	}
	
	/// Adds the feed(s) to the list of feeds that the user is following.
	///
	/// - parameter feedURLs: An array of feed urls that the user wishes to follow.
	/// - parameter completion: A block that will receive a boolean which indicates if the adding the feeds succeeded.
	public func startFollowingFeeds(feedUrls: [String], completion: (success: Bool) -> Void) {
		let params = ["feeds": JSON(feedUrls).rawString()!]
		let request = self.requestWithEndPoint(.StartFollowingFeeds, method: .POST, parameters: params)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion)
		}
	}
	
	/// Removes the feed from the list of feeds that the user is following.
	///
	/// - parameter feedID: The ID of the feed that the user doesn't want to follow anymore.
	/// - parameter completion: A block that will receive a boolean which indicates if the adding the feeds succeeded.
	public func stopFollowingFeed(feedID: String, completion: (success: Bool) -> Void) {
		let request = self.requestWithEndPoint(.StopFollowingFeed, pathComponents: [feedID], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion)
		}
	}
	
	/// Retrieves a list of feed items (articles) for a feed.
	///
	/// - parameter feedID: The ID of the feed for which to retrieve a list of feed items.
	/// - parameter completion: A block that will receive an array with the feed items.
	public func getFeedItemsForFeed(feed: Feed, completion: (articles: [Article]?) -> Void) {
		if let id = feed.id {
			let request = self.requestWithEndPoint(.GetFeedItems, pathComponents: [id], method: .GET)
			self.sendAsynchronousRequest(request) { (response, error) -> Void in
				if let res = response {
					let json = JSON.parse(res)
					var articles = [Article]()
					
					for (_, value):(String, JSON) in json {
						if let title = value["title"].string, url = value["url"].string, summary = value["summary"].string, date = value["published"].string {
							articles.append(Article(feed: feed, title: title, url: url, date: date, summary: summary))
						}
					}
					completion(articles: articles)
				} else {
					completion(articles: nil)
				}
			}
		} else {
			completion(articles: nil)
		}
	}
	
	/// Retrieves a list of news feed that a user could start following.
	///
	/// - parameter language: The ID of the feed for which to retrieve a list of feed items.
	/// - parameter completion: A block that will receive an array with the feed items.
	public func getInterestingFeeds(language: String, completion: (feeds: [Feed]?) -> Void) {
		let request = self.requestWithEndPoint(.GetInterestingFeeds, pathComponents: [language], method: .GET)
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			if let res = response, json = JSON.parse(res).array {
				var feeds = [Feed]()
				
				for value in json {
					if let title = value["title"].string, url = value["url"].string, id = value["id"].int, desc = value["description"].string, imURL = value["image_url"].string {
						feeds.append(Feed(id: String(id), title: title, url: url, description: desc, language: language, imageURL: imURL))
					}
				}
				completion(feeds: feeds)
			} else {
				completion(feeds: nil)
			}
		}
	}
	
	/// Sends user activity data to the server, where it is stored for further analysis.
	///
	/// - parameter language: The ID of the feed for which to retrieve a list of feed items.
	/// - parameter completion: A block that will receive an array with the feed items.
	public func uploadUserActivityData(event: String, value: String, extraData: [String: AnyObject]?, completion: (success: Bool) -> Void) {
		var extraData = extraData
		var params = ["event": event, "value": value]
		
		let formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "GMT")
		formatter.dateFormat = "y-MM-dd'T'HH:mm:ss"
		params["time"] = formatter.stringFromDate(NSDate())
		
		if extraData == nil {
			extraData = [:]
		}
		
		if let ed = extraData, json = try? NSJSONSerialization.dataWithJSONObject(ed, options: NSJSONWritingOptions(rawValue: 0)), str = NSString(data: json, encoding: NSUTF8StringEncoding) as? String {
			params["extra_data"] = str
		}
		
		let request = self.requestWithEndPoint(.UploadUserActivityData, method: .POST, parameters: params)
		
		self.sendAsynchronousRequest(request) { (response, error) -> Void in
			self.checkBooleanResponse(response, error: error, completion: completion)
		}
	}
	
}
