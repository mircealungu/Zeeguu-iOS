//
//  MasterViewController.swift
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

class ArticleListViewController: UITableViewController {

	var objects = [Article]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.estimatedRowHeight = 80
		
		self.title = "Zeeguu"
		self.navigationItem.title = "Zeeguu"
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			self.clearsSelectionOnViewWillAppear = true
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
		objects.insert(Article(articleTitle: "Innenminister ärgern sich über lange Asylverfahren", articleUrl: "http://www.t-online.de/nachrichten/deutschland/id_76314572/frank-juergen-weise-geraet-wegen-langer-asylverfahren-in-die-kritik.html", articleDate: "2015-12-04 15:19", articleSource: "T-Online"), atIndex: 0)
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let queueCell = tableView.dequeueReusableCellWithIdentifier("Cell")
		var cell: UITableViewCell
		if let c = queueCell {
			cell = c
		} else {
			cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
		}
		
		let article = objects[indexPath.row]
		let articleView = ArticleListView(article: article)
		
		cell.contentView.addSubview(articleView)
		let views = ["v":articleView]
		cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[v]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[v]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
		
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
		    objects.removeAtIndex(indexPath.row)
		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let article = objects[indexPath.row]
		let vc = ArticleViewController(article: article)
		
		if let split = self.splitViewController {
			var controllers = split.viewControllers
			controllers.removeLast()
			
			let nav = UINavigationController(rootViewController: vc)
			
			vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
			vc.navigationItem.leftItemsSupplementBackButton = true
			split.showDetailViewController(nav, sender: self)
			if let sv = self.splitViewController {
				UIApplication.sharedApplication().sendAction(sv.displayModeButtonItem().action, to: sv.displayModeButtonItem().target, from: nil, forEvent: nil)
			}
		} else {
			vc.hidesBottomBarWhenPushed = true
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}
}

