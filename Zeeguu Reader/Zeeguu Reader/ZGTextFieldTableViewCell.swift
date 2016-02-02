//
//  ZGTextFieldTableViewCell.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 12-12-15.
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

class ZGTextFieldTableViewCell: UITableViewCell {
	
	let titleLabel = UILabel.autoLayoutCapable()
	var textField: UITextField?
	var leftBoundary = 120
	
	convenience init(title: String, textField: UITextField, reuseIdentifier: String? = nil) {
		self.init(style: .Default, reuseIdentifier: reuseIdentifier)
		
		self.selectionStyle = .None
		
		let tapper = UITapGestureRecognizer(target: self, action: "didTapCell:")
		self.addGestureRecognizer(tapper)
		
		titleLabel.text = title
		titleLabel.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
		
		self.textField = textField
		
		self.contentView.addSubview(titleLabel)
		self.contentView.addSubview(textField)
		
		let views: [String: AnyObject] = ["title": titleLabel, "textField": textField]
		
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=left)-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["left": leftBoundary], views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[title]-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textField]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
	}
	
	func didTapCell(sender: UITapGestureRecognizer) {
		self.textField?.becomeFirstResponder()
	}
}
