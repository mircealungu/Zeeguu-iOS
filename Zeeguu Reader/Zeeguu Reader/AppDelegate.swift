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
import Zeeguu_API_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?

	private var becomesActiveDate: NSDate?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		let selector = #selector(AppDelegate.userLoggedIn(_:))
		NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UserLoggedInNotification, object: nil)
		
		let def = NSUserDefaults.standardUserDefaults()
		if def.objectForKey(InsertTranslationInTextDefaultsKey) == nil {
			def.setBool(true, forKey: InsertTranslationInTextDefaultsKey)
			def.synchronize()
		}
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window?.backgroundColor = UIColor.whiteColor()
		self.setupArticleRootViewController()
		
		let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
		dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
			if (!ZeeguuAPI.sharedAPI().isLoggedIn) {
				self.presentLogin()
			}
		}
		return true
	}
	
	func setupArticleRootViewController() {
		let toolbarVC = UITabBarController()
		
		let mainVC = UINavigationController(rootViewController: FeedOverviewTableViewController())
		let bookmarkVC = UINavigationController(rootViewController: HistoryTableViewController())
		let profileVC = UINavigationController(rootViewController: ProfileTableViewController())
		
		toolbarVC.viewControllers = [mainVC, bookmarkVC, profileVC]
		
		let splitViewController = UISplitViewController()
		let detailVC = UINavigationController(rootViewController: ArticleViewController())
		splitViewController.viewControllers = [toolbarVC, detailVC]
		detailVC.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
		splitViewController.delegate = self
		
		self.window?.rootViewController = splitViewController
		self.window?.makeKeyAndVisible()
	}
	
	func presentLogin() {
		let vc = UINavigationController(rootViewController: LoginRegisterTableViewController())
		vc.modalPresentationStyle = .FormSheet
		self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
	}
	
	func userLoggedIn(notification: NSNotification) {
		let def = NSUserDefaults.standardUserDefaults()
		if def.boolForKey(DidShowWelcomeScreenKey) == false {
			def.setBool(true, forKey: DidShowWelcomeScreenKey)
			def.synchronize()
			
			let vc = UINavigationController(rootViewController: WelcomeViewController())
			vc.modalPresentationStyle = .FormSheet
			self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
		}
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		guard let date = becomesActiveDate else {
			return
		}
		let interval = -date.timeIntervalSinceNow
		Utils.sendMonitoringStatusToServer("userUsedAppInSeconds", value: String(interval))
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
		becomesActiveDate = NSDate()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	// MARK: - Split view

	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
		if let secondaryAsNavController = secondaryViewController as? UINavigationController, topAsDetailController = secondaryAsNavController.topViewController as? ArticleViewController {
			if let art = topAsDetailController.article {
				if let tabBarController = primaryViewController as? UITabBarController, selectedNVC = tabBarController.selectedViewController as? UINavigationController, topVC = selectedNVC.topViewController as? ArticleListViewController where topVC.articles.contains(art) {
					secondaryAsNavController.setViewControllers([ArticleViewController()], animated: false)
					secondaryAsNavController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem() // Make sure navigation controller does not become empty
					
					selectedNVC.pushViewController(topAsDetailController, animated: true)
				} else if let tabBarController = primaryViewController as? UITabBarController, firstNVC = tabBarController.viewControllers?[0] as? UINavigationController, topVC = firstNVC.topViewController as? ArticleListViewController where topVC.articles.contains(art) {
					secondaryAsNavController.setViewControllers([ArticleViewController()], animated: false)
					secondaryAsNavController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem() // Make sure navigation controller does not become empty
					
					firstNVC.pushViewController(topAsDetailController, animated: false)
				}
				
			} else {
				// Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
				return true
			}
		}
	    return false
	}
	
	func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
		if let tabBarController = primaryViewController as? UITabBarController, selectedNVC = tabBarController.selectedViewController as? UINavigationController, topVC = selectedNVC.topViewController as? ArticleViewController {
			// There is an article viewController in the sidebar, move it to detailViewController of splitview
			selectedNVC.popViewControllerAnimated(true)
			return UINavigationController(rootViewController: topVC)
		}
		return nil
	}
	
	func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
		if splitViewController.collapsed {
			let tabBarController = splitViewController.viewControllers.first as! UITabBarController
			let selectedNavigationViewController = tabBarController.selectedViewController as! UINavigationController
			
			// Push view controller
			var viewControllerToPush = vc
			if let navController = vc as? UINavigationController {
				viewControllerToPush = navController.topViewController!
			}
			selectedNavigationViewController.pushViewController(viewControllerToPush, animated: true)
			
			return true
		}
		
		return false
	}
}

