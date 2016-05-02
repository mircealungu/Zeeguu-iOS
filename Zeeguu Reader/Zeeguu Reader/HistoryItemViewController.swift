//
//  HistoryItemViewController.swift
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

class HistoryItemViewController: UIViewController {

	let bookmark: Bookmark
	private let historyItemView: HistoryItemView
	
	init(bookmark: Bookmark) {
		self.bookmark = bookmark
		self.historyItemView = HistoryItemView(bookmark: self.bookmark)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		
		self.title = bookmark.word
		
		if let nav = self.navigationController {
			self.historyItemView.setSuperViewWidth(nav.view.frame.size.width)
		} else {
			self.historyItemView.setSuperViewWidth(self.view.frame.size.width)
		}
		
		let views: [String: AnyObject] = ["sv": self.historyItemView]
		self.view.addSubview(self.historyItemView)
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}
