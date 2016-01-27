//
//  ArticleView.swift
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
import ZeeguuAPI


class ArticleView: UIView {
	
	var article: Article!
	var titleLabel: UILabel?
	var contentView: ZGTextView?
	var delegate: ArticleViewDelegate?
	
	convenience init(article: Article, delegate: ArticleViewDelegate?) {
		self.init()
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
		self.delegate = delegate
		
		
		
		titleLabel = UILabel.autoLayoutCapapble()
		titleLabel?.text = article.title
		titleLabel?.numberOfLines = 0;
		titleLabel?.font = UIFont.boldSystemFontOfSize(20)
		
		print("fontsize: \(titleLabel?.font.pointSize)")
		
		contentView = ZGTextView(article: self.article)
		contentView?.editable = false;
		contentView?.textContainerInset = UIEdgeInsetsZero
		contentView?.textContainer.lineFragmentPadding = 0
		
		print("fontsize: \(contentView?.font)")
		
		article.getContents { (contents) -> Void in
			self.contentView?.text = contents
			self.delegate?.articleContentsDidLoad()
		}
		
		
		let views: [String: UIView] = ["title":titleLabel!, "content": contentView!]
		
		self.addSubview(titleLabel!)
		self.addSubview(contentView!)
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[title]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[content]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-[content]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		print("subviews: \(contentView?.subviews)")
		
		self.addConstraint(NSLayoutConstraint(item: contentView!, attribute: .Height, relatedBy: .Equal, toItem: contentView!.subviews[0], attribute: .Height, multiplier: 1, constant: 0))
	}
	
	override func layoutSubviews() {
		titleLabel?.preferredMaxLayoutWidth = self.frame.width - 20
		super.layoutSubviews()
	}

}

protocol ArticleViewDelegate {
	func articleContentsDidLoad()
}
