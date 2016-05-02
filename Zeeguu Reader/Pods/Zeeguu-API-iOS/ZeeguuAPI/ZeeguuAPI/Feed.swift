//
//  Feed.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 18-01-16.
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

public func ==(lhs: Feed, rhs: Feed) -> Bool {
	return lhs.title == rhs.title && lhs.url == rhs.url && lhs.feedDescription == rhs.feedDescription && lhs.language == rhs.language && lhs.imageURL == rhs.imageURL
}

public class Feed: CustomStringConvertible, Equatable {
	
	public var id: String?
	public var title: String
	public var url: String
	public var feedDescription: String
	public var language: String
	
	private var imageURL: String
	private var image: UIImage?
	
	public var description: String {
		return "Feed: {\n\tid: \"\(id)\",\n\ttitle: \"\(title)\",\n\turl: \"\(url)\",\n\tdescription: \"\(feedDescription)\",\n\tlanguage: \"\(language)\",\n\timageURL: \"\(imageURL)\"\n}"
	}
	
	init(id: String? = nil, title: String, url: String, description: String, language: String, imageURL: String) {
		self.id = id
		self.title = title
		self.url = url
		self.feedDescription = description
		self.language = language
		self.imageURL = imageURL
	}
	
	public func getImage(completion: (image: UIImage?) -> Void) {
		if let imURL = NSURL(string: self.imageURL) {
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
