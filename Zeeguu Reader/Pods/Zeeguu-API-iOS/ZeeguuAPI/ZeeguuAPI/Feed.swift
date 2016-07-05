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

/// Adds support for comparing `Feed` objects using the equals operator (`==`)
///
/// - parameter lhs: The left `Feed` operand of the `==` operator (left hand side) <pre><b>lhs</b> == rhs</pre>
/// - parameter rhs: The right `Feed` operand of the `==` operator (right hand side) <pre>lhs == <b>rhs</b></pre>
/// - returns: A `Bool` that states whether the two `Feed` objects are equal
public func ==(lhs: Feed, rhs: Feed) -> Bool {
	return lhs.title == rhs.title && lhs.url == rhs.url && lhs.feedDescription == rhs.feedDescription && lhs.language == rhs.language && lhs.imageURL == rhs.imageURL
}

/// The `Feed` class represents an RSS feed. It holds the `id`, `title`, `url`, `feedDescription`, `language` and more about the feed.
public class Feed: CustomStringConvertible, Equatable, ZGSerializable {
	
	// MARK: Properties -
	
	/// The id of this feed
	public var id: String?
	/// The title of this feed
	public var title: String
	/// The url of this feed
	public var url: String
	/// The description of this feed
	public var feedDescription: String
	/// The language of this feed
	public var language: String
	
	private var imageURL: String
	private var image: UIImage?
	
	/// The description of this `Feed` object. The value of this property will be used whenever the system tries to print this `Feed` object or when the system tries to convert this `Feed` object to a `String`.
	public var description: String {
		return "Feed: {\n\tid: \"\(id)\",\n\ttitle: \"\(title)\",\n\turl: \"\(url)\",\n\tdescription: \"\(feedDescription)\",\n\tlanguage: \"\(language)\",\n\timageURL: \"\(imageURL)\"\n}"
	}
	
	// MARK: Constructors -
	
	/**
	Construct a new `Feed` object.
	
	- parameter id: The id of this feed
	- parameter title: The title of the feed
	- parameter url: The url of the feed
	- parameter description: The description of the feed
	- parameter language: The language of the feed
	- parameter imageURL: The url for the image of the feed
	*/
	public init(id: String? = nil, title: String, url: String, description: String, language: String, imageURL: String) {
		self.id = id
		self.title = title
		self.url = url
		self.feedDescription = description
		self.language = language
		self.imageURL = imageURL
	}
	
	/**
	Construct a new `Feed` object from the data in the dictionary.
	
	- parameter dictionary: The dictionary that contains the data from which to construct an `Feed` object.
	*/
	@objc public required init?(dictionary dict: [String : AnyObject]) {
		guard let title = dict["title"] as? String,
			url = dict["url"] as? String,
			feedDescription = dict["feedDescription"] as? String,
			language = dict["language"] as? String,
			imageURL = dict["imageURL"] as? String else {
				return nil
		}
		self.id = dict["id"] as? String
		self.title = title
		self.url = url
		self.feedDescription = feedDescription
		self.language = language
		self.imageURL = imageURL
		self.image = dict["image"] as? UIImage
	}
	
	// MARK: Methods -
	
	/**
	The dictionary representation of this `Feed` object.
	
	- returns: A dictionary that contains all data of this `Feed` object.
	*/
	@objc public func dictionaryRepresentation() -> [String: AnyObject] {
		var dict = [String: AnyObject]()
		dict["id"] = self.id
		dict["title"] = self.title
		dict["url"] = self.url
		dict["feedDescription"] = self.feedDescription
		dict["language"] = self.language
		dict["imageURL"] = self.imageURL
		dict["image"] = self.image
		return dict
	}
	
	/**
	Get the image of this feed. This method will make sure that the image url is cached within this `Feed` object, so calling this method again will not retrieve the image again, but will return the cached version instead.
	
	- parameter completion: A closure that will be called once the image has been retrieved. If there was no image to retrieve, `image` is `nil`. Otherwise, it contains the feed image.
	*/
	public func getImage(completion: (image: UIImage?) -> Void) {
		if let imURL = NSURL(string: self.imageURL) {
			let request = NSMutableURLRequest(URL: imURL)
			ZeeguuAPI.sharedAPI().sendAsynchronousRequestWithDataResponse(request) { (data, error) -> Void in
				if let res = data {
					completion(image: UIImage(data: res))
				} else {
					if ZeeguuAPI.sharedAPI().enableDebugOutput {
						print("Could not get image with url '\(self.imageURL)', error: \(error)")
					}
					completion(image: nil)
				}
			}
		} else {
			completion(image: nil)
		}
	}
}
