//
//  MasterViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit

class ArticleListViewController: UITableViewController {

	var detailViewController: ArticleViewController? = nil
	var objects = [Article]()


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
//		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		self.tableView.estimatedRowHeight = 80
		
		self.navigationItem.title = "Zeeguu"
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
		    self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ArticleViewController
		}
	}

	override func viewWillAppear(animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
		super.viewWillAppear(animated)
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

//	// MARK: - Segues
//
//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//		if segue.identifier == "showDetail" {
//		    if let indexPath = self.tableView.indexPathForSelectedRow {
//		        let object = objects[indexPath.row] as! NSDate
//		        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ArticleViewController
//		        controller.detailItem = object
//		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//		        controller.navigationItem.leftItemsSupplementBackButton = true
//		    }
//		}
//	}

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
//		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		
//		let object = objects[indexPath.row] as! NSDate
//		cell.textLabel!.text = object.description
		
		
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
		if let split = self.splitViewController {
			let article = objects[indexPath.row]
			var controllers = split.viewControllers
			controllers.removeLast()
			
			let vc = ArticleViewController(article: article)
			let nav = UINavigationController(rootViewController: vc)
			
			
			//			let controller = (controllers[controllers.count - 1] as! UINavigationController).topViewController as! WebViewController
			//			controller.detailItem = object
			vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
			vc.navigationItem.leftItemsSupplementBackButton = true
			//			split.viewControllers = controllers
			//			split.viewWillAppear(true)
			split.showDetailViewController(nav, sender: nil)
		}
	}
}

