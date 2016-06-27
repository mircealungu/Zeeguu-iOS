//
//  Article.swift
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

/// Adds support for comparing `Article` objects using the equals operator (`==`)
///
/// - parameter lhs: The left `Article` operand of the `==` operator (left hand side) <pre><b>lhs</b> == rhs</pre>
/// - parameter rhs: The right `Article` operand of the `==` operator (right hand side) <pre>lhs == <b>rhs</b></pre>
/// - returns: A `Bool` that states whether the two `Article` objects are equal
public func ==(lhs: Article, rhs: Article) -> Bool {
	return lhs.feed == rhs.feed && lhs.title == rhs.title && lhs.url == rhs.url && lhs.date == rhs.date && lhs.summary == rhs.summary
}

/// The `Article` class represents an article. It holds the source (`feed`), `title`, `url`, `date`, `summary` and more about the article.
public class Article: CustomStringConvertible, Equatable, ZGSerialization {
	
	// MARK: Properties -
	
	/// The `Feed` from which this article was retrieved
	public var feed: Feed
	/// The title of this article
	public var title: String
	/// The url of this article
	public var url: String
	/// The publication date of this article
	public var date: NSDate
	/// The summary of this article
	public var summary: String
	/// Wheter this article has been read by the user. This propery is purely for use within an app. This boolean will not be populated from the server.
	public var isRead: Bool
	/// Wheter this article has been starred by the user. This propery is purely for use within an app. This boolean will not be populated from the server.
	public var isStarred: Bool
	
	private var imageURL: String?
	private var image: UIImage?
	private var contents: String?
	private var difficulty: ArticleDifficulty?
	
	/// Whether the contents of this article have been retrieved yet
	public var isContentLoaded: Bool {
		return contents != nil
	}
	
	/// Whether the difficulty of this article has been calculated yet
	public var isDifficultyLoaded: Bool {
		return difficulty != nil
	}
	
	/// The description of this `Article` object. The value of this property will be used whenever the system tries to print this `Article` object or when the system tries to convert this `Article` object to a `String`.
	public var description: String {
		let str = feed.description.stringByReplacingOccurrencesOfString("\n", withString: "\n\t")
		return "Article: {\n\tfeed: \"\(str)\",\n\ttitle: \"\(title)\",\n\turl: \"\(url)\",\n\tdate: \"\(date)\",\n\tsummary: \"\(summary)\",\n\tcontents: \"\(contents)\"\n}"
	}
	
	// MARK: Static methods -
	
	/// Get difficulty for all given articles
	///
	/// Note: This method uses the default difficulty computer.
	///
	/// - parameter articles: The articles for which to get difficulties. Please note that all `Article` objects are references and once `completion` is called, the given `Article` objects have difficulties.
	/// - parameter completion: A block that will indicate success. If `success` is `true`, all `Article` objects have been given their difficulty. Otherwise nothing has happened to the `Article` objects. If `articles` is empty, `success` is `false`.
	public static func getDifficultiesForArticles(articles: [Article], completion: (success: Bool) -> Void) {
		self.getContentsForArticles(articles, withDifficulty: true, completion: completion)
	}
	
	/// Get contents for all given articles
	///
	/// - parameter articles: The articles for which to get contents. Please note that all `Article` objects are references and once `completion` is called, the given `Article` objects have contents.
	/// - parameter withDifficulty: Whether to calculate difficulty for the retrieved contents. Setting this to `true` will send the language code of the first article's feed as the language of all contents.
	/// - parameter completion: A block that will indicate success. If `success` is `true`, all `Article` objects have been given their contents. Otherwise nothing has happened to the `Article` objects. If `articles` is empty, `success` is `false`.
	public static func getContentsForArticles(articles: [Article], withDifficulty: Bool = false, completion: (success: Bool) -> Void) {
		let urls = articles.flatMap({ $0.isContentLoaded && (!withDifficulty || $0.isDifficultyLoaded) ? nil : $0.url })
		if urls.count == 0 {
			return completion(success: false) // No articles to get content for
		}
		
		let langCode: String? = withDifficulty ? articles[0].feed.language : nil
		ZeeguuAPI.sharedAPI().getContentFromURLs(urls, langCode: langCode, maxTimeout: urls.count * 10) { (contents) in
			if let contents = contents {
				for i in 0 ..< contents.count {
					articles[i]._updateContents(contents[i], withDifficulty: withDifficulty)
				}
				return completion(success: true)
			}
			completion(success: false)
		}
	}
	
	// MARK: Constructors -
	
	/**
	Construct a new `Article` object.
	
	- parameter feed: The `Feed` from which this article was retrieved
	- parameter title: The title of the article
	- parameter url: The url of the article
	- parameter date: The publication date of the article
	- parameter summary: The summary of the article
	*/
	public init(feed: Feed, title: String, url: String, date: String, summary: String) {
		self.feed = feed
		self.title = title;
		self.url = url;
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "EN-US")
		formatter.dateFormat = "EEE, dd MMMM y HH:mm:ss Z"
		
		let date = formatter.dateFromString(date)
		self.date = date!
		self.summary = summary
		self.isRead = false
		self.isStarred = false
	}
	
	/**
	Construct a new `Article` object from the data in the dictionary.
	
	- parameter dictionary: The dictionary that contains the data from which to construct an `Article` object.
	*/
	@objc public required init?(dictionary dict: [String: AnyObject]) {
		var savedDate = dict["date"] as? NSDate
		if let date = dict["date"] as? String {
			let formatter = NSDateFormatter()
			formatter.locale = NSLocale(localeIdentifier: "EN-US")
			formatter.dateFormat = "EEE, dd MMMM y HH:mm:ss Z"
			
			let date = formatter.dateFromString(date)
			savedDate = date
		}
		guard let feed = dict["feed"] as? Feed,
			title = dict["title"] as? String,
			url = dict["url"] as? String,
			date = savedDate,
			summary = dict["summary"] as? String else {
				return nil
		}
		self.feed = feed
		self.title = title
		self.url = url
		self.date = date
		self.summary = summary
		self.isRead = dict["isRead"] as? Bool == true
		self.isStarred = dict["isStarred"] as? Bool == true
		self.imageURL = dict["imageURL"] as? String
		self.image = dict["image"] as? UIImage
		self.contents = dict["contents"] as? String
		if let difficulty = dict["difficulty"] as? String {
			self.difficulty = ArticleDifficulty(rawValue: difficulty)
		}
	}
	
	// MARK: Methods -
	
	/**
	The dictionary representation of this `Article` object.
	
	- returns: A dictionary that contains all data of this `Article` object.
	*/
	@objc public func dictionaryRepresentation() -> [String: AnyObject] {
		var dict = [String: AnyObject]()
		dict["feed"] = self.feed
		dict["title"] = self.title
		dict["url"] = self.url
		dict["date"] = self.date
		dict["summary"] = self.summary
		dict["isRead"] = self.isRead
		dict["isStarred"] = self.isStarred
		dict["imageURL"] = self.imageURL
		dict["image"] = self.image
		dict["contents"] = self.contents
		dict["difficulty"] = self.difficulty?.rawValue
		return dict
	}
	
	/**
	Get the contents of this article. This method will make sure that the contents are cached within this `Article` object, so calling this method again will not retrieve the contents again, but will return the cached version instead.
	
	- parameter completion: A closure that will be called once the contents have been retrieved. If there were no contents to retrieve, `contents` is the empty string. Otherwise, it contains the article contents.
	*/
	public func getContents(completion: (contents: String) -> Void) {
		if let c = contents {
			return completion(contents: c)
		}
		_getContents { (contents) in
			if let c = contents {
				return completion(contents: c.0)
			}
			completion(contents: "")
		}
	}
	
	/**
	Get the image of this article. This method will make sure that the image url is cached within this `Article` object, so calling this method again will not retrieve the image again, but will return the cached version instead.
	
	- parameter completion: A closure that will be called once the image has been retrieved. If there was no image to retrieve, `image` is `nil`. Otherwise, it contains the article image.
	*/
	public func getImage(completion: (image: UIImage?) -> Void) {
		_getContents { (contents) in
			if let c = contents, imURL = NSURL(string: c.1) {
				let request = NSMutableURLRequest(URL: imURL)
				ZeeguuAPI.sharedAPI().sendAsynchronousRequestWithDataResponse(request) { (data, error) -> Void in
					if let res = data {
						return completion(image: UIImage(data: res))
					}
					if ZeeguuAPI.sharedAPI().enableDebugOutput {
						print("Could not get image with url '\(self.imageURL)', error: \(error)")
					}
					completion(image: nil)
				}
			} else {
				completion(image: nil)
			}
		}
	}
	
	/**
	Get the difficulty of this article. This method will make sure that the difficulty is cached within this `Article` object, so calling this method again will not calculate the difficulty again, but will return the cached version instead.
	
	- parameter completion: A closure that will be called once the difficulty has been calculated. If there was no difficulty to calculate, `difficulty` is `ArticleDifficulty.Unknown`. Otherwise, it contains the article difficulty.
	*/
	public func getDifficulty(difficultyComputer: String = "default", completion: (difficulty: ArticleDifficulty) -> Void) {
		if let diff = difficulty {
			return completion(difficulty: diff)
		}
		if difficultyComputer == "default" {
			_getContents(true) { (contents) in
				if let c = contents {
					return completion(difficulty: c.2)
				}
				completion(difficulty: .Unknown)
			}
		} else {
			getContents({ (contents) in
				if contents == "" {
					return completion(difficulty: .Unknown)
				}
				ZeeguuAPI.sharedAPI().getDifficultyForTexts([contents], langCode: self.feed.language, difficultyComputer: difficultyComputer, completion: { (difficulties) in
					if let diffs = difficulties {
						self.difficulty = diffs[0]
						return completion(difficulty: diffs[0])
					}
					completion(difficulty: .Unknown)
				})
			})
		}
	}
	
	// MARK: -
	
	private func _updateContents(contents: (String, String, ArticleDifficulty), withDifficulty: Bool) {
		if contents.0 != "" {
			self.contents = contents.0
		}
		if contents.1 != "" {
			self.imageURL = contents.1
		}
		if withDifficulty {
			self.difficulty = contents.2
		}
	}
	
	private func _getContents(withDifficulty: Bool = false, completion: (contents: (String, String, ArticleDifficulty)?) -> Void) {
		if let con = contents, imURL = imageURL, diff = difficulty where withDifficulty == true {
			completion(contents: (con, imURL, diff))
		} else if let con = contents, imURL = imageURL where withDifficulty == false {
			completion(contents: (con, imURL, difficulty == nil ? .Unknown : difficulty!))
		} else {
			ZeeguuAPI.sharedAPI().getContentFromURLs([url]) { (contents) in
				if let content = contents?[0] {
					self._updateContents(content, withDifficulty: withDifficulty)
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completion(contents: content)
					})
				} else {
					if ZeeguuAPI.sharedAPI().enableDebugOutput {
						print("Failure, no content")
					}
				}
			}
		}
	}
}
