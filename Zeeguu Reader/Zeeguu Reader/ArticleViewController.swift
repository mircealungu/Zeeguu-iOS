//
//  ArticleViewController.swift
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
import Zeeguu_API_iOS

class ArticleViewController: UIViewController {
	
	var article: Article?
	private var articleView: ArticleView
	
	init(article: Article? = nil) {
		self.article = article
		self.articleView = ArticleView(article: self.article)
		
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		let views: [String: AnyObject] = ["v": articleView]
		
		self.view.addSubview(articleView)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		let translateBut = UIBarButtonItem(title: "TRANSLATION_MODE".localized, style: .Plain, target: self, action: #selector(ArticleViewController.toggleTranslationMode(_:)))
//		self.navigationItem.rightBarButtonItem = translateBut
		
		
		
		let butSmaller = UIBarButtonItem(title: "A", style: .Plain, target: articleView, action: #selector(ArticleView.decreaseFontSize(_:)))
		let butLarger = UIBarButtonItem(title: "A", style: .Plain, target: articleView, action: #selector(ArticleView.increaseFontSize(_:)))
		butSmaller.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(13)], forState: .Normal)
		butLarger.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(21)], forState: .Normal)
		
		if article == nil {
			translateBut.enabled = false;
			butSmaller.enabled = false;
			butLarger.enabled = false;
		}
		
		self.navigationItem.rightBarButtonItems = [translateBut, butLarger, butSmaller]
		
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let bookmarkItem = UIMenuItem(title: "TRANSLATE".localized, action: NSSelectorFromString("translate:"))
		
		mc.menuItems = [bookmarkItem]
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}
	
	func toggleTranslationMode(sender: UIBarButtonItem) {
		let sheet = UIAlertController(title: "TRANSLATION_MODE".localized, message: "TRANSLATION_MODE_DESCRIPTION".localized, preferredStyle: .ActionSheet)
		
		sheet.addAction(UIAlertAction(title: "INSTANT_TRANSLATION".localized, style: .Default, handler: { (action) -> Void in
			self.articleView.contentView.willInstantlyTranslate = true
		}))
		
		sheet.addAction(UIAlertAction(title: "ASK_BEFORE_TRANSLATION".localized, style: .Default, handler: { (action) -> Void in
			self.articleView.contentView.willInstantlyTranslate = false
		}))
		
		sheet.popoverPresentationController?.barButtonItem = sender
		
		self.presentViewController(sheet, animated: true, completion: nil)
	}
}

