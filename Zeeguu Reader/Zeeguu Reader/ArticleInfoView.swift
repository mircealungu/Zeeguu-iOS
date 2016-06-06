//
//  ArticleInfoView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 06-06-16.
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

class ArticleInfoView: UIView {

	let label: UILabel
	var text: String {
		get {
			guard let t = label.text else {
				return ""
			}
			return t
		}
		set {
			label.text = newValue
		}
	}
	
	var width: CGFloat {
		get {
			return label.preferredMaxLayoutWidth + 40
		}
		set {
			if newValue > 20 {
				label.preferredMaxLayoutWidth = newValue - 40
			}
		}
	}
	
	init() {
		label = UILabel.autoLayoutCapable()
		super.init(frame: CGRectZero)
		self.translatesAutoresizingMaskIntoConstraints = false
		
		label.numberOfLines = 0
		
		let effect = UIBlurEffect(style: .ExtraLight)
		let ev = UIVisualEffectView(effect: effect)
		ev.translatesAutoresizingMaskIntoConstraints = false
		
		let views = ["l": label, "ev": ev]
		
		self.addSubview(ev)
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[ev]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[ev]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addSubview(label)
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[l]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[l]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.layer.cornerRadius = 10
		self.clipsToBounds = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
