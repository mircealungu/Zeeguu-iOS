//
//  ArticleViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
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

class ArticleViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
	
	var article: Article?
//	private var _articleView: ArticleView
//	var articleView: ArticleView {
//		get {
//			return _articleView
//		}
//	}
	
	private var _webview: ZGWebView?
	private(set) var webview: ZGWebView { // _webview will never be nil when the initializer is finished
		get {
			return _webview!
		}
		set {
			_webview = newValue
		}
	}
	
	private var _translationMode = ArticleViewTranslationMode.Instant
	var translationMode: ArticleViewTranslationMode {
		get {
			return _translationMode
		}
		set(mode) {
			_translationMode = mode
			let action = ZGJavaScriptAction.ChangeTranslationMode(_translationMode == .Instant)
			webview.evaluateJavaScript(action.getJavaScriptExpression()) { (result, error) in
				print("result: \(result)")
				print("error: \(error)")
			}
		}
	}
	
	init(article: Article? = nil) {
		self.article = article
		//		self._articleView = ArticleView(article: self.article)
		super.init(nibName: nil, bundle: nil)
		
		let controller = WKUserContentController()
		controller.addScriptMessageHandler(self, name: "zeeguu")
		let config = WKWebViewConfiguration()
		config.userContentController = controller
		self.webview = ZGWebView(article: self.article, webViewConfiguration: config)
		
		self.webview.navigationDelegate = self
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
//		let views: [String: AnyObject] = ["v": _articleView]
		let views: [String: AnyObject] = ["v": webview]
		
//		self.view.addSubview(_articleView)
		self.view.addSubview(webview)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
//		let jsBut = UIBarButtonItem(title: "Execute JS".localized, style: .Plain, target: self, action: #selector(ArticleViewController.doJS(_:)))
//		self.navigationItem.leftBarButtonItem = jsBut
		
		let optionsBut = UIBarButtonItem(title: "OPTIONS".localized, style: .Plain, target: self, action: #selector(ArticleViewController.showOptions(_:)))
		self.navigationItem.rightBarButtonItem = optionsBut
		
//		if let str = article?.url, url = NSURL(string: "http://www.readability.com/m?url=\(str)") {
//			webview.loadRequest(NSURLRequest(URL: url))
//		}
		if let str = article?.url, url = NSURL(string: str) {
			webview.loadRequest(NSURLRequest(URL: url))
		}

		if article == nil {
			optionsBut.enabled = false;
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let bookmarkItem = UIMenuItem(title: "TRANSLATE".localized, action: NSSelectorFromString("translate:"))
		
		mc.menuItems = [bookmarkItem]
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}
	
	func showOptions(sender: UIBarButtonItem) {
		let vc = ArticleViewOptionsTableViewController(parent: self)
		vc.popoverPresentationController?.barButtonItem = sender
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
//	func doJS(sender: UIBarButtonItem) {
//		let jsFilePath = NSBundle.mainBundle().pathForResource("SelectionScripts", ofType: "js")
//		if let jsf = jsFilePath, jsFile = try? String(contentsOfFile: jsf) {
//			webview.evaluateJavaScript(jsFile, completionHandler: { (data, error) in
//				print("data: \(data)")
//				print("error: \(error)")
//			})
//		}
//	}
	
	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		Utils.loadJSFileToWebView(webView, jsFileName: "jquery-2.2.3.min")
		Utils.loadJSFileToWebView(webView, jsFileName: "SelectionScripts")
	}
	
	func translate(action: ZGJavaScriptAction) {
		var action = action
		if let word = action.getActionInformation()?["word"], context = action.getActionInformation()?["context"], art = article {
			ZeeguuAPI.sharedAPI().translateWord(word, title: art.title, context: context, url: art.url /* TODO: Or maybe webview url? */, completion: { (translation) in
				if let t = translation?["translation"].string {
					print("\"\(word)\" translated to \"\(t)\"")
					action.setTranslation(t)
					self.webview.evaluateJavaScript(action.getJavaScriptExpression(), completionHandler: { (result, error) in
						print("result: \(result)")
						print("error: \(error)")
					})
				}
			})
		}
	}
	
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		print("Received message: \(message.body)")
		if let dict = message.body as? Dictionary<String, String> {
			let action = ZGJavaScriptAction.parseMessage(dict)
			
			switch action {
			case .Translate(_):
				self.translate(action)
			default:
				break
			}
		}
	}

}

