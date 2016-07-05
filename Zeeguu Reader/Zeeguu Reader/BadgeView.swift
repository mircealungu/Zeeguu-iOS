//
//  BadgeView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 23-06-16.
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

class BadgeView: UIView {

	let label: UILabel
	init(text: String) {
		self.label = UILabel.autoLayoutCapable()
		super.init(frame: CGRectZero)
		
		label.text = text
		label.textColor = UIColor.whiteColor()
		label.sizeToFit()
		
		self.backgroundColor = UIColor.lightGrayColor()
		self.layer.cornerRadius = 10
		self.clipsToBounds = true
		
		self.addSubview(label)
		let views = ["l": label]
		
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[l]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[l]-1-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		var f = self.frame
		f.size.width = 8 + label.frame.size.width + 8
		f.size.height = 1 + label.frame.size.height + 1
		self.frame = f
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// If a UITableViewCell is selected, all subviews are given a transparent background color, to make things look nicely.
	// The background color property is overridden here, to avoid the badge from being temporarily invisible.
	override var backgroundColor: UIColor? {
		get {
			return super.backgroundColor
		}
		set {
			super.backgroundColor = UIColor.lightGrayColor()
		}
	}
}
