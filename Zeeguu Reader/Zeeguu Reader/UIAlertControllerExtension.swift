//
//  UIAlertControllerExtension.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 28-06-16.
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

extension UIAlertController {
	
	static func showOKAlertWithTitle(title: String, message: String, okAction: ((UIAlertAction) -> Void)?) {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK".localized, style: .Default, handler: okAction))
			
			UIViewController.currentViewController()?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	static func showBinaryAlertWithTitle(title: String, message: String, yesAction: ((UIAlertAction) -> Void)?, noAction: ((UIAlertAction) -> Void)? = nil) {
		dispatch_async(dispatch_get_main_queue()) { () -> Void in
			let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "YES".localized, style: .Default, handler: yesAction))
			alert.addAction(UIAlertAction(title: "NO".localized, style: .Cancel, handler: noAction))
			
			UIViewController.currentViewController()?.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
}
