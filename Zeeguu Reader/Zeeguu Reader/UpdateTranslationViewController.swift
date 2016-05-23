//
//  UpdateTranslationViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 23-05-16.
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

protocol UpdateTranslationViewControllerDelegate {
	
	func updateTranslationViewControllerDidChangeTranslationTo(translation: String)
	
}

class UpdateTranslationViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	
	var delegate: UpdateTranslationViewControllerDelegate?
	
	let oldTranslation: String
	
	init(oldTranslation: String) {
		self.oldTranslation = oldTranslation
		super.init(nibName: nil, bundle: nil)
		
		self.modalPresentationStyle = .Popover
		self.popoverPresentationController?.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let label = UILabel.autoLayoutCapable()
		label.text = "NEW_TRANSLATION:".localized
		
		let tf = UITextField.autoLayoutCapable()
		tf.text = oldTranslation
		tf.textColor = UIColor(red:56.0/255.0, green:84.0/255.0, blue:135.0/255.0, alpha:1.0);
		tf.addTarget(self, action: #selector(UpdateTranslationViewController.updateTranslation(_:)), forControlEvents: .PrimaryActionTriggered)
		tf.autocapitalizationType = .None
		tf.becomeFirstResponder()
		
		self.view.addSubview(label)
		self.view.addSubview(tf)
		
		let views = ["lab": label, "tf": tf]
		
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[lab]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[tf]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[lab]-8-[tf]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.preferredContentSize = CGSizeMake(300, 10 + 21 + 8 + 25 + 10)
    }
	
	func updateTranslation(sender: UITextField) {
		sender.resignFirstResponder()
		if let text = sender.text, del = delegate where text != oldTranslation {
			del.updateTranslationViewControllerDidChangeTranslationTo(text)
		}
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
}
