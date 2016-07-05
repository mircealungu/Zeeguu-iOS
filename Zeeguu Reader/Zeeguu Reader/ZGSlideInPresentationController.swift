//
//  ZGSlideInPresentationController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 10-06-16.
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

@objc protocol ZGSlideInPresentationControllerDelegate {
	
	@objc func dismissViewController(sender: UITapGestureRecognizer)
	
}

class ZGSlideInNavigationController: UINavigationController, ZGSlideInPresentationControllerDelegate {
	
	func dismissViewController(sender: UITapGestureRecognizer) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}

class ZGSlideInPresentationController: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

	private var isPresenting: Bool = false
	private var presentDuration: NSTimeInterval = 0.5
	private var presentDimView: UIView = UIView()
	private var presentedViewController: UIViewController
	
	init(presentedViewController: UIViewController) {
		self.presentedViewController = presentedViewController
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = true
		return self
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		isPresenting = false;
		return self
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return presentDuration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView();
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
		
		if(self.isPresenting == true) {
			self.presentDimView = UIView(frame: CGRectMake(0, 0, 1024, 1024))
			self.presentDimView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
			self.presentDimView.alpha = 0
			
			if let vc = toViewController as? ZGSlideInPresentationControllerDelegate {
				let selector = #selector(ZGSlideInPresentationControllerDelegate.dismissViewController(_:))
				let recog = UITapGestureRecognizer(target: vc, action: selector)
				self.presentDimView.addGestureRecognizer(recog)
			}
			
			containerView!.addSubview(self.presentDimView)
			containerView!.addSubview(toViewController!.view)
			toViewController!.view.frame = CGRectMake(fromViewController!.view.frame.size.width, 0, 320, UIScreen.mainScreen().bounds.size.height)
			UIView.animateWithDuration(presentDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () in
				self.presentDimView.alpha = 1
				fromViewController?.view.tintAdjustmentMode = .Dimmed
				toViewController!.view.frame = CGRectMake(fromViewController!.view.frame.size.width - 320, 0, 320, UIScreen.mainScreen().bounds.size.height)
				}, completion: { (completed) in
					transitionContext.completeTransition(completed)
			})
			
		} else {
			UIView.animateWithDuration(presentDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () in
				fromViewController!.view.frame = CGRectMake(toViewController!.view.frame.size.width, 0, 320, UIScreen.mainScreen().bounds.size.height)
				self.presentDimView.alpha = 0
				toViewController?.view.tintAdjustmentMode = .Automatic
				}, completion: { (completed) in
					fromViewController?.view.removeFromSuperview()
					self.presentDimView.removeFromSuperview()
					transitionContext.completeTransition(completed)
			})
		}
	}
	
	func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition(nil, completion: { (context) in
			if let window = UIApplication.sharedApplication().delegate?.window, windowRect = window?.frame where self.isPresenting {
				var f = self.presentedViewController.view.frame
				let windowWidth = windowRect.size.width
				
				f.origin.x = windowWidth - 320
				f.size.width = 320
				self.presentedViewController.view.frame = f
			}
		})
	}

}
