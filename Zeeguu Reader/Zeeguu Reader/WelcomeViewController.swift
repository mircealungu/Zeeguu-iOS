//
//  WelcomeViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 12-06-16.
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

class WelcomeViewController: UIViewController, UIScrollViewDelegate {
	
	private var pager: UIPageControl!
	private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "APP_TITLE".localized
		self.view.backgroundColor = UIColor.whiteColor()
		
		scrollView = UIScrollView.autoLayoutCapable()
		scrollView.pagingEnabled = true
		scrollView.delegate = self
		self.automaticallyAdjustsScrollViewInsets = false;
		self.view.addSubview(scrollView)
		
		pager = UIPageControl.autoLayoutCapable()
		pager.numberOfPages = 4
		pager.addTarget(self, action: #selector(WelcomeViewController.pagerDidChangeToPage(_:)), forControlEvents: .ValueChanged)
		pager.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
		pager.layer.cornerRadius = 10
		pager.clipsToBounds = true
		self.view.addSubview(pager)
		
		var views: [String: AnyObject] = ["sv": scrollView, "top": self.topLayoutGuide, "pager": pager]
		
		for idx in 1...4 {
			let image = UIImage(named: "welcome\(idx)")
			let iv = UIImageView.autoLayoutCapable()
			iv.image = image
			iv.contentMode = .ScaleAspectFit
			scrollView.addSubview(iv)
			
			views["iv\(idx)"] = iv
		}
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top][sv]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .CenterX, relatedBy: .Equal, toItem: pager, attribute: .CenterX, multiplier: 1, constant: 0))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[pager(==70)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pager(==20)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[iv1(==sv)][iv2(==sv)][iv3(==sv)][iv4(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv1(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv2(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv3(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv4(==sv)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func scrollViewDidScroll(scrollView: UIScrollView) {
		let pageWidth = scrollView.frame.size.width
		let page = lround(Double(scrollView.contentOffset.x) / Double(pageWidth))
		self.pager.currentPage = page
		
		if page == 3 {
			let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(WelcomeViewController.dismiss(_:)))
			self.navigationItem.rightBarButtonItem = done
		}
	}
	
	func pagerDidChangeToPage(sender: UIPageControl) {
		let page = sender.currentPage
		var offset = scrollView.contentOffset
		let pageWidth = scrollView.frame.size.width
		offset.x = CGFloat(page) * pageWidth
		scrollView.setContentOffset(offset, animated: true)
	}
	
	func dismiss(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}
