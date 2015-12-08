//
//  ArticleListView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit

class ArticleListView: UIView {
	
	var article: Article!
	
	convenience init(article: Article) {
		self.init()
		self.article = article;
		self.translatesAutoresizingMaskIntoConstraints = false
		
		
		
		
		
		let titleLabel = UILabel.autoLayoutCapapble()
		titleLabel.text = article.title
		
		let sourceLabel = UILabel.autoLayoutCapapble()
		sourceLabel.text = article.source
		
		let dateLabel = UILabel.autoLayoutCapapble()
		dateLabel.text = article.date
		
		
		let views = ["title":titleLabel, "source":sourceLabel, "date": dateLabel]
		
		self.addSubview(titleLabel)
		self.addSubview(sourceLabel)
		self.addSubview(dateLabel)
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[title]-[date]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[source]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-[source]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[date]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
	}
	
}
