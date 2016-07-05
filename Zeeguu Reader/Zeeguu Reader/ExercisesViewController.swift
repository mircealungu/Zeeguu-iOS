//
//  ExercisesViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 25-06-16.
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
import WebKit
import Zeeguu_API_iOS

class ExercisesViewController: UIViewController, WKNavigationDelegate {

	private let webview: ZGWebView
	
	init() {
		self.webview = ZGWebView()
		super.init(nibName: nil, bundle: nil)
		self.webview.navigationDelegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "EXERCISES".localized
		
		self.view.backgroundColor = UIColor.whiteColor()
		let views: [String: AnyObject] = ["v": webview]
		
		self.view.addSubview(webview)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		let request = ZeeguuAPI.getLoginWithSessionRequest()
		if let url = request.URL?.absoluteString, method = request.HTTPMethod, body = request.HTTPBody, params = String(data: body, encoding: NSUTF8StringEncoding) {
			let action = ZGJavaScriptAction.SendPOSTRequest(url, method, params)
			self.webview.executeJavaScriptAction(action, resultHandler: { (obj) in
				print("obj: \(obj)")
			})
		}
    }
	
	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		self.webview.executeJavaScriptAction(.GetPageText) { (result) in
			print("result: \(result)")
			if let res = result as? String where res == "OK" {
				self.webview.loadRequest(ZeeguuAPI.getMobileExercisesRequest())
			}
		}
	}

}
