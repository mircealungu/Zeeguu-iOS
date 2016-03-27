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
import Zeeguu_API_iOS


class ArticleView: UIScrollView {
	
	var article: Article?
	var titleLabel: UILabel
	var contentView: ZGTextView
	
	private let refresher: UIRefreshControl
	
	init(article: Article?) {
		self.article = article;
		self.refresher = UIRefreshControl()
		
		self.titleLabel = UILabel.autoLayoutCapable()
		self.contentView = ZGTextView(article: self.article)
		
		super.init(frame: CGRectZero)
		
		setupLayout()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func setupLayout() {
		self.translatesAutoresizingMaskIntoConstraints = false
		
		let view = UIView.autoLayoutCapable()
		self.addSubview(view)
		
		titleLabel.numberOfLines = 0;
		titleLabel.font = UIFont.boldSystemFontOfSize(20)
		
		contentView.editable = false;
		contentView.textContainerInset = UIEdgeInsetsZero
		contentView.textContainer.lineFragmentPadding = 0
		
		if let art = article {
			titleLabel.text = art.title
			self.indicateLoadingArticle(true)
			art.getContents { (contents) -> Void in
				self.contentView.text = contents
				self.indicateLoadingArticle(false)
			}
		}
		
		
		let views: [String: UIView] = ["sv": self, "v": view, "title": titleLabel, "content": contentView]
		
		view.addSubview(titleLabel)
		view.addSubview(contentView)
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[title]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[content]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-[content]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .Equal, toItem: contentView.subviews[0], attribute: .Height, multiplier: 1, constant: 0))
	}
	
	override func layoutSubviews() {
		titleLabel.preferredMaxLayoutWidth = self.frame.width - 20
		super.layoutSubviews()
	}
	
	private func indicateLoadingArticle(loading: Bool) {
		if loading {
			self.addSubview(refresher)
			refresher.beginRefreshing()
		} else {
			// This delay (execution of the CATransaction calls is delayed by 0.1 seconds)
			// is there to prevent glitching in the interface.
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
				// This enables us to attach a completion block to the animation, removing the refresher before
				// animation is complete also causes glitching.
				CATransaction.begin()
				CATransaction.setCompletionBlock({ () -> Void in
					self.refresher.removeFromSuperview()
				})
				self.refresher.endRefreshing()
				CATransaction.commit()
			}
		}
	}

}
