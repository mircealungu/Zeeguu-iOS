//
//  ArticleViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
	
	var article: Article?
	
	convenience init(article: Article) {
		self.init()
		self.article = article
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = UIColor.whiteColor()
		if let art = article {
			let view = ArticleView(article: art)
			let views: [String: AnyObject] = ["v":view, "top":self.topLayoutGuide]
			
			self.view.addSubview(view)
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
			self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[top][v]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		let menuItem = UIMenuItem(title: "Translate", action: "translate:")
		let menuItem2 = UIMenuItem(title: "Bookmark", action: "bookmark:")
		
		mc.menuItems = [menuItem, menuItem2]
	}
	
	override func viewDidDisappear(animated: Bool) {
		let mc = UIMenuController.sharedMenuController()
		
		mc.menuItems = nil
	}


}

