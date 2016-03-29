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

public class Article: CustomStringConvertible {
	public var feed: Feed
	public var title: String
	public var url: String
	public var date: String
	public var summary: String
	private var contents: String?
	
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
		if let con = contents {
			completion(contents: con)
		} else {
			ZeeguuAPI.sharedAPI().getContentFromURLs([url]) { (dict) -> Void in
				if let content = dict!["contents"][0]["content"].string {
					self.contents = content
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
