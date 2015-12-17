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
	
	convenience init(article: Article) {
		self.init()
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
		
		
		
		
		let titleLabel = UILabel.autoLayoutCapapble()
		titleLabel.text = article.title
		
		let contentLabel = ZGTextView(article: self.article)
		contentLabel.editable = false;
		
		if let contents = article.contents {
			contentLabel.text = contents
		} else {
			ZeeguuAPI.sharedAPI().getContentFromURLs([article.url]) { (dict) -> Void in
				if let content = dict!["contents"][0]["content"].string {
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						contentLabel.text = content
//						print("Content: \(content)")
						
//						let fixedWidth = contentLabel.frame.size.width
////						contentLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//						let newSize = contentLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
//						var newFrame = contentLabel.frame
//						newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//						contentLabel.frame = newFrame;
//						contentLabel.scrollEnabled = false
//						
////						self.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
						
//						contentLabel.layoutManager.ensureLayoutForTextContainer(contentLabel.textContainer)
//						let containerSize = contentLabel.layoutManager.usedRectForTextContainer(contentLabel.textContainer)
//						let height = ceil(containerSize.height + contentLabel.textContainerInset.top + contentLabel.textContainerInset.bottom)
//						let f = contentLabel.frame
//						contentLabel.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, height)
						
					})
				} else {
					print("Failure, no content")
				}
			}
		}
		
		
		let views = ["title":titleLabel, "content": contentLabel]
		
		self.addSubview(titleLabel)
		self.addSubview(contentLabel)
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[title]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[content]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-[content]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
	}

}
