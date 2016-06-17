//
//  LoadingView.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 17-06-16.
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

class ZGLoadingView: UIView {

	let effectView: UIVisualEffectView
	let activityIndicator: UIActivityIndicatorView
	
	init() {
		let effect = UIBlurEffect(style: .Dark)
		effectView = UIVisualEffectView(effect: effect)
		activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		super.init(frame: CGRectZero)
		
		self.layer.cornerRadius = 10
		self.clipsToBounds = true
		
		effectView.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		
		let views = ["a": activityIndicator, "ev": effectView]
		
		self.addSubview(effectView)
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[ev]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[ev]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.addSubview(activityIndicator)
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[a]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[a]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		activityIndicator.startAnimating()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
