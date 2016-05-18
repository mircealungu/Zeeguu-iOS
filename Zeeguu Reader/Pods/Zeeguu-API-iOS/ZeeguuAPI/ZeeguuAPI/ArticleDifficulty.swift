//
//  ArticleDifficulty.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 26-04-16.
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

/// The `ArticleDifficulty` is a measure of how easy it is for a user to understand an `Article`. This difficulty is usually calculated based on which words of the foreign language are already known to the user.
public enum ArticleDifficulty: String, CustomStringConvertible {
	
	//MARK: Enum values -
	
	/// It is easy for the user to understand the article
	case Easy = "EASY"
	/// It is doable for the user to understand the article, but he/she might need some help (by translating words/phrases) to completely understand the article.
	case Medium = "MEDIUM"
	/// It is difficult for the user to understand the article and he/she will probably need to translate a lot of words/phrases
	case Hard = "HARD"
	/// The difficulty is unknown, because it wasn't calculated or failed to calculate
	case Unknown = "UNKNOWN"
	
	// MARK: Properties -
	
	/// The description of this `ArticleDifficulty` object. The value of this property will be used whenever the system tries to print this `ArticleDifficulty` object or when the system tries to convert this `ArticleDifficulty` object to a `String`.
	public var description: String {
		return self.rawValue.localized
	}
	
	/// The color associated with the difficulty. Depending the value of this object, it is either green (`ArticleDifficulty.Easy`), orange (`ArticleDifficulty.Medium`), red (`ArticleDifficulty.Hard`) or light gray (`ArticleDifficulty.Unknown`).
	public var color: UIColor {
		switch self {
		case .Easy:
			return UIColor.greenColor()
		case .Medium:
			return UIColor.orangeColor()
		case .Hard:
			return UIColor.redColor()
		case .Unknown:
			return UIColor.lightGrayColor()
		}
	}
}
