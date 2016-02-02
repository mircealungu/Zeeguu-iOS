//
//  HistoryItemViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 27-01-16.
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
import ZeeguuAPI

class HistoryItemViewController: UIViewController {

	let bookmark: Bookmark
	
	private let translationLabel = UILabel.autoLayoutCapable()
	private let languageLabel = UILabel.autoLayoutCapable()
	private let contextLabel = UILabel.autoLayoutCapable()
	
	init(bookmark: Bookmark) {
		self.bookmark = bookmark
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		
		self.title = bookmark.word
		
		let sv = UIScrollView.autoLayoutCapable()
		let v = UIView.autoLayoutCapable()
		
		translationLabel.numberOfLines = 0;
		languageLabel.numberOfLines = 0;
		contextLabel.numberOfLines = 0;
		
		if let nav = self.navigationController {
			translationLabel.preferredMaxLayoutWidth = nav.view.frame.size.width - 40
			languageLabel.preferredMaxLayoutWidth = nav.view.frame.size.width - 40
			contextLabel.preferredMaxLayoutWidth = nav.view.frame.size.width - 40
		} else {
			translationLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 40
			languageLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 40
			contextLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 40
		}
		
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
		
		var context: NSAttributedString
		if let c = bookmark.context where c.characters.count > 0 {
			context = NSAttributedString(string: c)
		} else {
			context = NSAttributedString(string: "NO_CONTEXT".localized, attributes: [NSFontAttributeName: UIFont.italicSystemFontOfSize(contextLabel.font.pointSize)])
		}
			let attrStr = NSMutableAttributedString()
			attrStr.appendAttributedString(NSAttributedString(string: String(format: "CONTEXT_OF_%@".localized, arguments: [bookmark.word]), attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(contextLabel.font.pointSize)]))
			attrStr.appendAttributedString(NSAttributedString(string: "\n"))
			
			let contextAttr = NSMutableAttributedString(attributedString: context)
			
			let regex = try! NSRegularExpression(pattern: "(\(bookmark.word))", options: [])
			let range = NSMakeRange(0, contextAttr.length)
			
			regex.enumerateMatchesInString(context.string, options: [], range: range, usingBlock: { (results, flags, stop) -> Void in
				let substringRange = results?.rangeAtIndex(1);
				if let r = substringRange {
					contextAttr.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(self.contextLabel.font.pointSize)], range: r)
				}
			})
			
			attrStr.appendAttributedString(contextAttr)
			
			contextLabel.attributedText = attrStr
		
		let views: [String: AnyObject] = ["v": v, "sv": sv, "t": translationLabel, "l": languageLabel, "c": contextLabel]
		
		self.view.addSubview(sv)
		sv.addSubview(v)
		v.addSubview(translationLabel)
		v.addSubview(languageLabel)
		v.addSubview(contextLabel)
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[t]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[l]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[c]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[t][l]-[c]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
