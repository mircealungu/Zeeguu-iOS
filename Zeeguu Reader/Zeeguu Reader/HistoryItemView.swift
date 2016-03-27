//
//  HistoryItemView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 02-02-16.
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

import Zeeguu_API_iOS

class HistoryItemView: UIScrollView {
	
	private let bookmark: Bookmark
	
	private let translationLabel: UILabel
	private let languageLabel: UILabel
	private let contextLabel: UILabel
	
	init(bookmark: Bookmark) {
		self.bookmark = bookmark
		
		self.translationLabel = UILabel.autoLayoutCapable()
		self.languageLabel = UILabel.autoLayoutCapable()
		self.contextLabel = UILabel.autoLayoutCapable()
		
		super.init(frame: CGRectZero)
		
		setupLayout()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setSuperViewWidth(width: CGFloat) {
		translationLabel.preferredMaxLayoutWidth = width - 40
		languageLabel.preferredMaxLayoutWidth = width - 40
		contextLabel.preferredMaxLayoutWidth = width - 40
	}
	
	private func setupSubViews() {
		translationLabel.numberOfLines = 0;
		languageLabel.numberOfLines = 0;
		contextLabel.numberOfLines = 0;
		
		
		
		translationLabel.font = UIFont.boldSystemFontOfSize(20)
		languageLabel.font = UIFont.systemFontOfSize(14)
		languageLabel.textColor = UIColor.lightGrayColor()
		contextLabel.font = UIFont.systemFontOfSize(16)
		
		translationLabel.text = String(format: "TRANSLATED_TO_%@%@".localized, arguments: [bookmark.word, bookmark.translation[0]])
		let languageName = LanguagesTableViewController.getEnglishNameForLanguageCode(bookmark.wordLanguage)
		if let lang = languageName {
			languageLabel.text = String(format: "WORD_IS_LANGUAGE_%@%@".localized, arguments: [bookmark.word, lang])
		} else {
			languageLabel.text = String(format: "WORD_IS_LANGUAGE_%@%@".localized, arguments: [bookmark.word, "'" + bookmark.wordLanguage + "'"])
		}
		
		contextLabel.attributedText = getContextString()
	}
	
	private func getContextString() -> NSAttributedString {
		var context: NSAttributedString
		if let c = bookmark.context where c.characters.count > 0 {
			context = NSAttributedString(string: c)
		} else {
			context = NSAttributedString(string: "NO_CONTEXT".localized, attributes: [NSFontAttributeName: UIFont.italicSystemFontOfSize(contextLabel.font.pointSize)])
		}
		
		// Add bold header (in English, it will say Context:)
		let attrStr = NSMutableAttributedString()
		attrStr.appendAttributedString(NSAttributedString(string: String(format: "CONTEXT_OF_%@".localized, arguments: [bookmark.word]), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(contextLabel.font.pointSize)]))
		attrStr.appendAttributedString(NSAttributedString(string: "\n"))
		
		
		let contextAttr = NSMutableAttributedString(attributedString: context)
		
		let regex = try! NSRegularExpression(pattern: "(\(bookmark.word))", options: [])
		let range = NSMakeRange(0, contextAttr.length)
		
		// Find all occurences of the word that was translated and make it bold.
		regex.enumerateMatchesInString(context.string, options: [], range: range, usingBlock: { (results, flags, stop) -> Void in
			let substringRange = results?.rangeAtIndex(1);
			if let r = substringRange {
				contextAttr.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(self.contextLabel.font.pointSize)], range: r)
			}
		})
		
		attrStr.appendAttributedString(contextAttr)
		return attrStr
	}
	
	private func setupLayout() {
		self.translatesAutoresizingMaskIntoConstraints = false
		let v = UIView.autoLayoutCapable()
		
		setupSubViews()
		
		let views: [String: AnyObject] = ["v": v, "sv": self, "t": translationLabel, "l": languageLabel, "c": contextLabel]
		
		self.addSubview(v)
		v.addSubview(translationLabel)
		v.addSubview(languageLabel)
		v.addSubview(contextLabel)
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[t]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[l]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[c]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[t][l]-[c]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
	}

}
