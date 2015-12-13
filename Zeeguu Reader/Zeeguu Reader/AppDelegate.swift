///
//  AppDelegate.swift
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
import ZeeguuAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window?.backgroundColor = UIColor.whiteColor()
		self.setupArticleRootViewcontroller()
		
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
			if (!ZeeguuAPI.sharedAPI().isLoggedIn) {
				let vc = UINavigationController(rootViewController: LoginRegisterTableViewController())
				vc.modalPresentationStyle = .FormSheet
				self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
			}
		}
		return true
	}
	
	func setupArticleRootViewcontroller() {
		let mainVC = UINavigationController(rootViewController: ArticleListViewController())
		let toolbarVC = UITabBarController()
		
		let item = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Favorites, tag: 0)
		mainVC.tabBarItem = item
		
		toolbarVC.viewControllers = [mainVC]
		
		if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
			self.window?.rootViewController = toolbarVC
		} else {
			let splitViewController = UISplitViewController()
			let detailVC = UINavigationController(rootViewController: ArticleViewController())
			splitViewController.viewControllers = [toolbarVC, detailVC]
			detailVC.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
			splitViewController.delegate = self
			
			self.window?.rootViewController = splitViewController
		}
		self.window?.makeKeyAndVisible()
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Split view

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
//	    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
//	    guard let topAsDetailController = secondaryAsNavController.topViewController as? ArticleViewController else { return false }
//	    if topAsDetailController.detailItem == nil {
//	        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//	        return true
//	    }
	    return true
	}
}

