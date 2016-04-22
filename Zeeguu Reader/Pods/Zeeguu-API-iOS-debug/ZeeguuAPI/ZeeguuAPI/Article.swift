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
	private var imageURL: String?
	private var image: UIImage?
	private var contents: String?
	private var personalDifficulty: String?
	private var generalDifficulty: String?
	
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
	
	public func setContents(contents: String) {
		self.contents = contents
	}
	
	public func setImageURL(imageURL: String) {
		self.imageURL = imageURL
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
	
	public func getDifficulty(personalized: Bool = true, completion: (difficulty: String) -> Void) {
		let difficulty = personalized ? personalDifficulty : generalDifficulty
		if let diff = difficulty {
			completion(difficulty: diff)
		} else {
			getContents({ (contents) in
				ZeeguuAPI.sharedAPI().getDifficultyForTexts([contents], langCode: self.feed.language, personalized: personalized, completion: { (dict) in
					if let d = dict {
						// process difficulty dictionary
					} else {
						ZeeguuAPI.sharedAPI().debugPrint("Failure, no difficulty")
					}
				})
			})
		}
	}
	
	private func _getContents(completion: (contents: (String, String)?) -> Void) {
		if let con = contents, imURL = imageURL {
			completion(contents: (con, imURL))
		} else {
			ZeeguuAPI.sharedAPI().getContentFromURLs([url]) { (dict) -> Void in
				if let content = dict!["contents"][0]["content"].string, imURL = dict!["contents"][0]["image"].string {
					self.contents = content
					self.imageURL = imURL
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						completion(contents: (content, imURL))
					})
				} else {
					ZeeguuAPI.sharedAPI().debugPrint("Failure, no content")
				}
			}
		}
	}
}
