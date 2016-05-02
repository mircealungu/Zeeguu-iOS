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

public func ==(lhs: Article, rhs: Article) -> Bool {
	return lhs.feed == rhs.feed && lhs.title == rhs.title && lhs.url == rhs.url && lhs.date == rhs.date && lhs.summary == rhs.summary
}

public class Article: CustomStringConvertible, Equatable {
	public var feed: Feed
	public var title: String
	public var url: String
	public var date: String
	public var summary: String
	
	public var isContentLoaded: Bool {
		return contents != nil
	}
	
	public var isDifficultyLoaded: Bool {
		return difficulty != nil
	}
	
	private var imageURL: String?
	private var image: UIImage?
	private var contents: String?
	private var difficulty: ArticleDifficulty?
	
	public var description: String {
		let str = feed.description.stringByReplacingOccurrencesOfString("\n", withString: "\n\t")
		return "Article: {\n\tfeed: \"\(str)\",\n\ttitle: \"\(title)\",\n\turl: \"\(url)\",\n\tdate: \"\(date)\",\n\tsummary: \"\(summary)\",\n\tcontents: \"\(contents)\"\n}"
	}
	
	public init(feed: Feed, title: String, url: String, date: String, summary: String) {
		self.feed = feed
		self.title = title;
		self.url = url;
		self.date = date;
		self.summary = summary
	}
	
	public func getContents(completion: (contents: String) -> Void) {
		_getContents { (contents) in
			if let c = contents {
				completion(contents: c.0)
			}
		}
	}
	
	public func getImage(completion: (image: UIImage?) -> Void) {
		_getContents { (contents) in
			if let c = contents, imURL = NSURL(string: c.1) {
				let request = NSMutableURLRequest(URL: imURL)
				ZeeguuAPI.sharedAPI().sendAsynchronousRequestWithDataResponse(request) { (data, error) -> Void in
					if let res = data {
						completion(image: UIImage(data: res))
					} else {
						ZeeguuAPI.sharedAPI().debugPrint("Could not get image with url '\(self.imageURL)', error: \(error)")
						completion(image: nil)
					}
				}
			} else {
				completion(image: nil)
			}
		}
	}
	
	public func getDifficulty(difficultyComputer: String = "default", completion: (difficulty: ArticleDifficulty) -> Void) {
		if let diff = difficulty {
			completion(difficulty: diff)
		} else {
			getContents({ (contents) in
				ZeeguuAPI.sharedAPI().getDifficultyForTexts([contents], langCode: self.feed.language, difficultyComputer: difficultyComputer, completion: { (difficulties) in
					if let diffs = difficulties {
						self.difficulty = diffs[0]
						completion(difficulty: diffs[0])
					} else {
						completion(difficulty: .Unknown)
					}
				})
			})
		}
	}
		
	
	/// Get difficulty for all given articles
	///
	/// - parameter articles: The articles for which to get difficulties. Please note that all `Article` objects are references and once `completion` is called, the given `Article` objects have difficulties.
	/// - parameter personalized: Calculate difficulty score specific for the current user.
	/// - parameter completion: A block that will indicate success. If `success` is `true`, all `Article` objects have been given their difficulty. Otherwise nothing has happened to the `Article` objects.
	public static func getDifficultiesForArticles(articles: [Article], personalized: Bool = true, completion: (success: Bool) -> Void) {
		self.getContentsForArticles(articles) { (success) in
			if (success) {
				var texts = [String]()
				for i in 0 ..< articles.count {
					if let c = articles[i].contents {
						texts.append(c)
					}
				}
				
				ZeeguuAPI.sharedAPI().getDifficultyForTexts(texts, langCode: articles[0].feed.language, completion: { (difficulties) in
					if let diffs = difficulties {
						for i in 0 ..< diffs.count {
							if !articles[i].isContentLoaded {
								continue
							}
							articles[i].difficulty = diffs[i]
						}
						completion(success: true)
					} else {
						completion(success: false)
					}
				})
			} else {
				completion(success: false)
			}
		}
	}
	
	/// Get contents for all given articles
	///
	/// - parameter articles: The articles for which to get contents. Please note that all `Article` objects are references and once `completion` is called, the given `Article` objects have contents.
	/// - parameter completion: A block that will indicate success. If `success` is `true`, all `Article` objects have been given their contents. Otherwise nothing has happened to the `Article` objects.
	public static func getContentsForArticles(articles: [Article], completion: (success: Bool) -> Void) {
		let urls = articles.map({ $0.url })
		
		ZeeguuAPI.sharedAPI().getContentFromURLs(urls, maxTimeout: urls.count * 10) { (contents) in
			if let contents = contents {
				for i in 0 ..< contents.count {
					let content = contents[i]
					
					if content.0 != "" {
						articles[i].contents = content.0
					}
					if content.1 != "" {
						articles[i].imageURL = content.1
					}
				}
				completion(success: true)
			} else {
				completion(success: false)
			}
		}
	}
	
	
	private func _getContents(completion: (contents: (String, String, ArticleDifficulty)?) -> Void) {
		if let con = contents, imURL = imageURL {
			completion(contents: (con, imURL, difficulty == nil ? .Unknown : difficulty!))
		} else {
			ZeeguuAPI.sharedAPI().getContentFromURLs([url]) { (contents) in
				if let content = contents?[0] {
					if content.0 != "" {
						self.contents = content.0
					}
					if content.1 != "" {
						self.imageURL = content.1
					}
					
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completion(contents: content)
					})
				} else {
					ZeeguuAPI.sharedAPI().debugPrint("Failure, no content")
				}
			}
		}
	}
}
