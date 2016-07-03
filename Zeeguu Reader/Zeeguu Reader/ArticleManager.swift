//
//  ArticleManager.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 23-06-16.
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
import Zeeguu_API_iOS

class ArticleManager {

	private static let instance = ArticleManager()
	static func sharedManager() -> ArticleManager {
		return instance
	}
	
	private var feeds: [Feed]
	
	var articles: [[Article]]
	
	private init() {
		self.feeds = []
		self.articles = []
		
	}
	
	private func _downloadArticles(feed: Feed, index i: Int) {
		let lock = NSCondition()
		lock.lock()
		
		ZeeguuAPI.sharedAPI().runCompletionOnMainThread = true
		ZeeguuAPI.sharedAPI().getFeedItemsForFeed(feed, completion: { (articles) -> Void in
			if let arts = articles {
				self.articles[i] = ArticleManager.mergeArticles(oldArticles:self.articles[i], newArticles: arts)
				ArticleManager.saveArticles(arts, forKey: articlesForFeedKey + feed.id!, overwriteExisting: false)
			}
			lock.signal()
		})
		lock.wait()
		lock.unlock()
	}
	
	func downloadArticles(feed: Feed? = nil) -> [Article] {
		if let feed = feed, i = self.feeds.indexOf(feed) {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
				self._downloadArticles(feed, index: i)
			})
		} else {
			for i in 0 ..< self.feeds.count {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
					self._downloadArticles(self.feeds[i], index: i)
				})
			}
		}
		return getArticles(feed)
	}
	
	func getArticles(feed: Feed? = nil) -> [Article] {
		if let feed = feed, i = self.feeds.indexOf(feed) {
			return self.articles[i]
		}
		var arts = [Article]()
		for i in 0 ..< self.feeds.count {
			arts = ArticleManager.mergeArticles(oldArticles: arts, newArticles: self.articles[i])
		}
		return arts
	}
	
	func countUnReadArticles(feed: Feed? = nil) -> Int {
		let arts = getArticles(feed)
		var counter = 0
		for art in arts {
			if !art.isRead {
				counter += 1
			}
		}
		return counter
	}
	
	func getFeeds() -> [Feed] {
		return self.feeds
	}
	
	func setFeeds(feeds: [Feed]) {
		self.feeds = feeds
		articles = []
		for f in self.feeds {
			articles.append(ArticleManager.loadArticles(forKey: articlesForFeedKey + f.id!))
		}
	}
	
	
	static func mergeArticles(oldArticles oldArticles: [Article], newArticles: [Article]) -> [Article] {
		var oldArticles = oldArticles
		for art in newArticles {
			if !oldArticles.contains({ $0 == art }) {
				oldArticles.append(art);
			}
		}
		
		oldArticles.sortInPlace({ (lhs, rhs) -> Bool in
			return lhs.date.compare(rhs.date) == NSComparisonResult.OrderedDescending
		})
		return oldArticles
	}
	
	static func replaceArticles(oldArticles oldArticles: [Article], newArticles: [Article]) -> [Article] {
		var oldArticles = oldArticles
		for art in newArticles {
			if oldArticles.contains({ $0 == art }) {
				oldArticles[oldArticles.indexOf(art)!] = art
			}
		}
		oldArticles.sortInPlace({ (lhs, rhs) -> Bool in
			return lhs.date.compare(rhs.date) == NSComparisonResult.OrderedDescending
		})
		return oldArticles
	}
	
	func updateLocalArticles(arts: [Article]) {
		var allArticles = [[Article]]()
		
		for _ in feeds {
			allArticles.append([Article]())
		}
		
		for a in arts {
			allArticles[feeds.indexOf(a.feed)!].append(a)
		}
		
		for i in 0 ..< feeds.count {
			ArticleManager.saveArticles(allArticles[i], forKey: articlesForFeedKey + feeds[i].id!)
		}
	}
	
	func save() {
		for i in 0 ..< feeds.count {
			ArticleManager.saveArticles(articles[i], forKey: articlesForFeedKey + feeds[i].id!)
		}
	}
	
	static func saveArticles(articles: [Article], forKey key: String, overwriteExisting overwrite: Bool = true) {
		let def = NSUserDefaults.standardUserDefaults()
		if let arr = def.objectForKey(key) as? [[String: AnyObject]], localArts = ZGSerialize.decodeArray(arr) as? [Article] {
			if overwrite {
				let newLocal = self.replaceArticles(oldArticles: localArts, newArticles: articles)
				def.setObject(ZGSerialize.encodeArray(newLocal), forKey: key)
			} else {
				let newLocal = self.mergeArticles(oldArticles: localArts, newArticles: articles)
				def.setObject(ZGSerialize.encodeArray(newLocal), forKey: key)
			}
		} else {
			def.setObject(ZGSerialize.encodeArray(articles), forKey: key)
		}
		def.synchronize()
	}
	
	static func loadArticles(forKey key: String) -> [Article] {
		let def = NSUserDefaults.standardUserDefaults()
		if let arr = def.objectForKey(key) as? [[String: AnyObject]], localArts = ZGSerialize.decodeArray(arr) as? [Article] {
			return localArts
		}
		return []
	}
	
}
