//
//  ArticleTableViewCell.swift
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
import Zeeguu_API_iOS

class ArticleTableViewCell: UITableViewCell {
	
	private var article: Article
	
	private var titleField: UILabel
	private var descriptionField: UILabel
	private var articleImageView: UIImageView
	private var unreadView: UIView
	
	private var difficultyLabel: UILabel
	private var difficultyView: DifficultyView
	
	init(article: Article, reuseIdentifier: String?) {
		self.article = article
		titleField = UILabel.autoLayoutCapable()
		descriptionField = UILabel.autoLayoutCapable()
		articleImageView = UIImageView.autoLayoutCapable()
		difficultyLabel = UILabel.autoLayoutCapable()
		difficultyView = DifficultyView()
		unreadView = UIView.autoLayoutCapable()
		super.init(style: .Default, reuseIdentifier: reuseIdentifier)
		setupLayout()
		updateLabels()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupLayout() {
		titleField.font = UIFont.boldSystemFontOfSize(12)
		titleField.numberOfLines = 2
		
		titleField.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
		titleField.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
		descriptionField.font = UIFont.systemFontOfSize(10)
		descriptionField.textColor = UIColor.lightGrayColor()
		descriptionField.numberOfLines = 0
		articleImageView.contentMode = .ScaleAspectFit
		
		difficultyLabel.text = ArticleDifficulty.Unknown.description
		difficultyLabel.font = UIFont.systemFontOfSize(12)
		
		unreadView.layer.cornerRadius = 5
		unreadView.clipsToBounds = true
		unreadView.backgroundColor = article.isRead ? UIColor(red: 0, green: 0, blue: 0, alpha: 0) : UIColor(red: 0.3, green: 0.3, blue: 1.0, alpha: 1)
		
		self.contentView.addSubview(titleField)
		self.contentView.addSubview(descriptionField)
		self.contentView.addSubview(articleImageView)
		self.contentView.addSubview(difficultyLabel)
		self.contentView.addSubview(difficultyView)
		self.contentView.addSubview(unreadView)
		
		let views: [String: UIView] = ["t": titleField, "d": descriptionField, "i": articleImageView, "diff": difficultyLabel, "diff2": difficultyView, "u": unreadView]
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[u(10)]-[i(60)]-[t]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[i]-[d]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[i]-[diff2(10)]-[diff]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[i(80)]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[t]-1-[diff]-1-[d]-(>=0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[diff2(10)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[u(10)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.contentView.addConstraint(NSLayoutConstraint(item: difficultyView, attribute: .CenterY, relatedBy: .Equal, toItem: difficultyLabel, attribute: .CenterY, multiplier: 1, constant: 0))
		self.contentView.addConstraint(NSLayoutConstraint(item: unreadView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
	}
	
	private func updateLabels() {
		titleField.text = article.title
		descriptionField.text = article.summary
		
		unreadView.backgroundColor = article.isRead ? UIColor(red: 0, green: 0, blue: 0, alpha: 0) : UIColor(red: 0.3, green: 0.3, blue: 1.0, alpha: 1)
		
		if self.article.isDifficultyLoaded {
			self.article.getDifficulty(completion: { (difficulty) in
				self.difficultyLabel.text = difficulty.description
				self.difficultyView.bgColor = difficulty.color
			})
		}
		
		article.feed.getImage { (image) -> Void in
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.articleImageView.image = image
			})
		}
	}
	
	func setArticle(article: Article) {
		self.article = article
		updateLabels()
	}

	func setArticleImage(image: UIImage) {
		self.articleImageView.image = image
	}
	

	class DifficultyView: UIView {
		
		private var _bgColor: UIColor?
		var bgColor: UIColor? {
			get {
				return _bgColor
			}
			set {
				_bgColor = newValue
				super.backgroundColor = newValue
			}
		}
		
		// If a UITableViewCell is selected, all subviews are given a transparent background color, to make things look nicely.
		// The background color property is overridden here, to avoid the difficulty color indication from being temporarily removed.
		override var backgroundColor: UIColor? {
			get {
				return super.backgroundColor
			}
			set {
				super.backgroundColor = self.bgColor
			}
		}
		
		init() {
			super.init(frame: CGRectZero)
			self.translatesAutoresizingMaskIntoConstraints = false
			
			self.layer.cornerRadius = 5
			self.clipsToBounds = true
			self.bgColor = ArticleDifficulty.Unknown.color
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}
	
}
