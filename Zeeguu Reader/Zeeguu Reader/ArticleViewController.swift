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
import AVFoundation
import WebKit
import Zeeguu_API_iOS

class ArticleViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, UpdateTranslationViewControllerDelegate, UIPopoverPresentationControllerDelegate {
	
	var article: Article?
	
	private var _webview: ZGWebView?
	private(set) var webview: ZGWebView { // _webview will never be nil when the initializer is finished
		get {
			return _webview!
		}
		set {
			_webview = newValue
		}
	}
	
	private var oldTranslationMode: ArticleViewTranslationMode?
	private var _translationMode = ArticleViewTranslationMode.Instant
	var translationMode: ArticleViewTranslationMode {
		get {
			return _translationMode
		}
		set(mode) {
			_translationMode = mode
			
			switch mode {
			case .Instant:
				Utils.sendMonitoringStatusToServer("userSwitchesToInstantTranslation", value: "1")
			case .WordPair:
				Utils.sendMonitoringStatusToServer("userSwitchesToWordPairTranslation", value: "1")
			case .Sentence:
				Utils.sendMonitoringStatusToServer("userSwitchesToSentenceTranslation", value: "1")
			}
			
			let action = ZGJavaScriptAction.ChangeTranslationMode(_translationMode)
			webview.executeJavaScriptAction(action)
		}
	}
	
	private var _disableLinks = false
	var disableLinks: Bool {
		get {
			return _disableLinks
		}
		set(disable) {
			_disableLinks = disable
			let action = ZGJavaScriptAction.DisableLinks(disable)
			
			if disable {
				Utils.sendMonitoringStatusToServer("userDisablesLinks", value: "1")
			} else {
				Utils.sendMonitoringStatusToServer("userEnablesLinks", value: "1")
			}
			
			webview.executeJavaScriptAction(action)
		}
	}
	
	private var infoViewShown: Bool = false
	private var infoView: ArticleInfoView
	private var infoViewBottomConstraint: NSLayoutConstraint!
	private var isPresentingInfoView: Bool = false
	private var shouldHideInfoViewAlready: Bool = true
	
	private var currentJavaScriptAction: ZGJavaScriptAction?
	
	private var slideInPresentationController: ZGSlideInPresentationController?
	
	init(article: Article? = nil) {
		self.infoView = ArticleInfoView()
		self.article = article
		//		self._articleView = ArticleView(article: self.article)
		super.init(nibName: nil, bundle: nil)
		
		self.hidesBottomBarWhenPushed = true
		
		let controller = WKUserContentController()
		controller.addScriptMessageHandler(self, name: "zeeguu")
		
		Utils.addUserScriptToUserContentController(controller, jsFileName: "jquery-2.2.3.min")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuVars")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuHelperFunctions")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuPageInteraction")
		Utils.addUserScriptToUserContentController(controller, jsFileName: "ZeeguuPagePreparation")
		Utils.addStyleSheetToUserContentController(controller, cssFileName: "zeeguu")
		
		let def = NSUserDefaults.standardUserDefaults()
		let inserts = def.boolForKey(InsertTranslationInTextDefaultsKey)
		Utils.addUserScriptToUserContentController(controller, js: ZGJavaScriptAction.SetInsertsTranslation(inserts).getJavaScriptExpression())
		
		let config = WKWebViewConfiguration()
		config.userContentController = controller
		self.webview = ZGWebView(webViewConfiguration: config)
		
		self.webview.navigationDelegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		let views: [String: AnyObject] = ["v": webview, "iv": infoView]
		
		self.view.addSubview(webview)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		self.view.addSubview(infoView)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[iv]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		if infoViewBottomConstraint == nil {
			self.infoViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: infoView, attribute: .Bottom, multiplier: 1, constant: -100)
		}
		self.view.addConstraint(infoViewBottomConstraint)
		
		
		let optionsBut = UIBarButtonItem(title: "OPTIONS".localized, style: .Plain, target: self, action: #selector(ArticleViewController.showOptions(_:)))
		self.navigationItem.rightBarButtonItem = optionsBut
		
		if let str = article?.url, url = NSURL(string: "http://www.readability.com/m?url=\(str)") {
			webview.loadRequest(NSURLRequest(URL: url))
		}
		//		if let str = article?.url, url = NSURL(string: str) {
		//			webview.loadRequest(NSURLRequest(URL: url))
		//		}
		
		if article == nil {
			optionsBut.enabled = false;
		}
		
		let didHideSelector = #selector(ArticleViewController.didHideUIMenuController(_:))
		NSNotificationCenter.defaultCenter().addObserver(self, selector: didHideSelector, name: UIMenuControllerDidHideMenuNotification, object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let bookmarkItem = UIMenuItem(title: "TRANSLATE".localized, action: #selector(ArticleViewController.translateSelection(_:)))
		
		mc.menuItems = [bookmarkItem]
	}
	
	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		if article != nil && !infoViewShown {
			showInfoView()
			infoViewShown = true
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}
	
	func showOptions(sender: UIBarButtonItem) {
		let vc = ArticleViewOptionsTableViewController(parent: self)
		vc.popoverPresentationController?.barButtonItem = sender
		vc.popoverPresentationController?.delegate = self
		oldTranslationMode = translationMode
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
	func showUpdateTranslation(sender: ZGJavaScriptAction) {
		let dict = sender.getActionInformation();
		guard let r = dict, old = r["oldTranslation"] else {
			return
		}
		let vc = UpdateTranslationViewController(oldTranslation: old, action: sender)
		
		vc.delegate = self;
		
		let nav = UINavigationController(rootViewController: vc)
		slideInPresentationController = ZGSlideInPresentationController(presentedViewController: nav)
		
		nav.transitioningDelegate = slideInPresentationController!;
		nav.modalPresentationStyle = .Custom
		
		currentJavaScriptAction = sender
		self.presentViewController(nav, animated: true, completion: nil)
	}
	
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		slideInPresentationController?.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
	}
	
	func updateTranslationViewControllerDidChangeTranslation(utvc: UpdateTranslationViewController, newTranslation: String, otherTranslations: [String : String]?) {
		var otherTranslations = otherTranslations
		print("new translation: \(newTranslation)")
		guard var act = currentJavaScriptAction, d = act.getActionInformation(), let bid = d["bookmarkID"], let old = d["oldTranslation"] else {
			currentJavaScriptAction = nil
			return
		}
		if var ot = otherTranslations {
			var add = true
			for (_, value) in ot {
				if value == newTranslation {
					add = false
				}
			}
			if add {
				ot[newTranslation] = newTranslation
				otherTranslations = ot
			}
		}
		
		if let ot = otherTranslations, jsonData = try? NSJSONSerialization.dataWithJSONObject(ot, options: NSJSONWritingOptions(rawValue: 0)), str = String(data: jsonData, encoding: NSUTF8StringEncoding) {
			act.setOtherTranslations(str)
		}
		
		ZeeguuAPI.sharedAPI().addNewTranslationToBookmarkWithID(bid, translation: newTranslation, completion: { (success) in
			if (success) {
				ZeeguuAPI.sharedAPI().deleteTranslationFromBookmarkWithID(bid, translation: old, completion: { (success) in})
			}
		})
		
		
		act.setTranslation(newTranslation)
		webview.executeJavaScriptAction(act)
		
		
		
		guard let actionInfo = currentJavaScriptAction?.getActionInformation() else {
			return
		}
		let data = ["actionInfo": String(actionInfo)]
		Utils.sendMonitoringStatusToServer("userEditedTranslation", value: "1", data: data)
		
		currentJavaScriptAction = nil
	}
	
	func updateTranslationViewControllerDidDeleteTranslation(utvc: UpdateTranslationViewController) {
		guard let act = currentJavaScriptAction, d = act.getActionInformation(), id = d["id"], bid = d["bookmarkID"] else {
			currentJavaScriptAction = nil
			return
		}
		let newAct = ZGJavaScriptAction.DeleteTranslation(id)
		ZeeguuAPI.sharedAPI().deleteBookmarkWithID(bid) { (success) in }
		self.webview.executeJavaScriptAction(newAct)
		
		guard let actionInfo = currentJavaScriptAction?.getActionInformation() else {
			return
		}
		let data = ["actionInfo": String(actionInfo)]
		Utils.sendMonitoringStatusToServer("userDeletedTranslation", value: "1", data: data)
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	func translateSelection(sender: AnyObject?) {
		if let action = currentJavaScriptAction {
			translateWithAction(action)
			currentJavaScriptAction = nil
		}
		self.webview.userInteractionEnabled = true
	}
	
	func translate(action: ZGJavaScriptAction) {
		if translationMode != .Instant {
			let mc = UIMenuController.sharedMenuController()
			let dict = action.getActionInformation();
			
			if let r = dict, rx = r["left"], ry = r["top"], rw = r["width"], rh = r["height"], x = Float(rx), y = Float(ry), w = Float(rw), h = Float(rh) {
				let topGuide = self.topLayoutGuide
				let rect = CGRectMake(CGFloat(x), CGFloat(y) + topGuide.length, CGFloat(w), CGFloat(h))
				
				currentJavaScriptAction = action
				
				self.webview.userInteractionEnabled = false
				
				self.becomeFirstResponder()
				mc.setTargetRect(rect, inView: webview)
				mc.setMenuVisible(true, animated: true)
			}
			return
		}
		translateWithAction(action)
	}
	
	func translateWithAction(action: ZGJavaScriptAction) {
		var action = action
		guard let word = action.getActionInformation()?["word"], context = action.getActionInformation()?["context"], art = article else {
			return
		}
		ZeeguuAPI.sharedAPI().translateWord(word, title: art.title, context: context, url: art.url /* TODO: Or maybe webview url? */, completion: { (translation) in
			print("translation: \(translation)")
			guard let t = translation?["translation"].string, b = translation?["bookmark_id"].string else {
				return
			}
			print("\"\(word)\" translated to \"\(t)\"")
			action.setTranslation(t)
			action.setBookmarkID(b)
			
			let def = NSUserDefaults.standardUserDefaults()
			if def.boolForKey(InsertTranslationInTextDefaultsKey) {
				self.webview.executeJavaScriptAction(action)
			} else {
				dispatch_sync(dispatch_get_main_queue(), {
					self.showInfoView(t)
				})
			}
			
			NSNotificationCenter.defaultCenter().postNotificationName(UserTranslatedWordNotification, object: nil)
			
			guard let trans = translation, actionInfo = action.getActionInformation() else {
				return
			}
			let data = ["translationResponse": String(trans), "actionInfo": String(actionInfo)]
			switch self.translationMode {
			case .Instant:
				Utils.sendMonitoringStatusToServer("userTranslatedUsingInstantTranslation", value: "1", data: data)
			case .WordPair:
				Utils.sendMonitoringStatusToServer("userTranslatedUsingWordPairTranslation", value: "1", data: data)
			case .Sentence:
				Utils.sendMonitoringStatusToServer("userTranslatedUsingSentenceTranslation", value: "1", data: data)
			}
			
			
		})
	}
	
	func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
		print("Received message: \(message.body)")
		guard let body = message.body as? Dictionary<String, AnyObject> else {
			return
		}
		var dict = Dictionary<String, String>()
		
		for (key, var value) in body {
			if let val = value as? NSObject where val == NSNull() {
				value = ""
			}
			dict[key] = String(value)
		}
		
		
		let action = ZGJavaScriptAction.parseMessage(dict)
		
		switch action {
		case .Translate(_):
			self.translate(action)
			break
		case .EditTranslation(_):
			self.showUpdateTranslation(action)
			break
		case .SelectionIncomplete:
			let controller = UIAlertController(title: "SELECTION_INVALID".localized, message: "SELECTION_INVALID_DESCRIPTION".localized, preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK".localized, style: .Default, handler: nil)
			controller.addAction(okAction)
			self.presentViewController(controller, animated: true, completion: nil)
			break
		case .Pronounce(_):
			self.pronounceWord(action)
			break
		default:
			break
		}
	}
	
	func didHideUIMenuController(sender: NSNotification) {
		self.webview.executeJavaScriptAction(ZGJavaScriptAction.RemoveSelectionHighlights)
		self.webview.userInteractionEnabled = true
		currentJavaScriptAction = nil
	}
	
	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		if action == #selector(ArticleViewController.translateSelection(_:)) && currentJavaScriptAction == nil {
			return false
		}
		return super.canPerformAction(action, withSender: sender)
	}
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
		if let old = oldTranslationMode where old != translationMode {
			showInfoView()
			oldTranslationMode = nil
		}
	}
	
	func showInfoView(text: String! = nil) {
		self.infoViewBottomConstraint.constant = 20
		if self.isPresentingInfoView {
			self.shouldHideInfoViewAlready = false
		}
		self.isPresentingInfoView = true
		UIView.animateWithDuration(1.0, animations: {
			self.infoView.text = text == nil ? self.translationMode.getDescription() : text
			self.view.layoutIfNeeded()
		}) { (finished) in
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
				if self.shouldHideInfoViewAlready == false {
					self.shouldHideInfoViewAlready = true
					return
				}
				self.isPresentingInfoView = false
				self.infoViewBottomConstraint.constant = -100
				UIView.animateWithDuration(1.0, animations: {
					self.view.layoutIfNeeded()
				}) { (finished) in
					self.infoView.text = ""
				}
			}
		}
	}
	
	func pronounceWord(action: ZGJavaScriptAction) {
		if let word = action.getActionInformation()?["word"] {
			_ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			_ = try? AVAudioSession.sharedInstance().setActive(true)
			
			let synthesizer = AVSpeechSynthesizer()
			
			let utterance = AVSpeechUtterance(string: word)
			utterance.voice = AVSpeechSynthesisVoice(language: self.article?.feed.language)
			
			synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
			synthesizer.speakUtterance(utterance)
			
			_ = try? AVAudioSession.sharedInstance().setActive(false)
			
			Utils.sendMonitoringStatusToServer("userPronouncesWord", value: "1")
		}
	}
}

