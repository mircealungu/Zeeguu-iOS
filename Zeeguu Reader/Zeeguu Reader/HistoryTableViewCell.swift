//
//  HistoryTableViewCell.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 11-06-16.
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

class HistoryTableViewCell: UITableViewCell {

	private var _bookmark: Bookmark
	var bookmark: Bookmark {
		get {
			return _bookmark
		}
		set {
			_bookmark = newValue
			self.titleLabel.text = _bookmark.word
			self.subtitleLabel.text = _bookmark.translation[0]
		}
	}
	
	let titleLabel: UILabel
	let subtitleLabel: UILabel
	
	init(bookmark: Bookmark, reuseIdentifier: String) {
		_bookmark = bookmark
		self.titleLabel = UILabel.autoLayoutCapable()
		self.subtitleLabel = UILabel.autoLayoutCapable()
		super.init(style: .Default, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .DisclosureIndicator
		self.titleLabel.text = _bookmark.word
		self.subtitleLabel.text = _bookmark.translation[0]
		setupLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupLayout() {
		self.titleLabel.textColor = UIColor(red:0.22, green:0.33, blue:0.53, alpha:1.0)
		
		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.subtitleLabel)
		
		let views = ["t": self.titleLabel, "s": self.subtitleLabel]
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[t]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[s]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[t]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[s]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .CenterY, relatedBy: .Equal, toItem: self.titleLabel, attribute: .Bottom, multiplier: 1, constant: 0))
		self.contentView.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .CenterY, relatedBy: .Equal, toItem: self.subtitleLabel, attribute: .Top, multiplier: 1, constant: 0))
	}
}
