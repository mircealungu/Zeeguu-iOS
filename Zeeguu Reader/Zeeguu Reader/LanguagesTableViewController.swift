//
//  LanguagesTableViewController.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 13-12-15.
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

enum LanguageChooseType {
	case BaseLanguage
	case LearnLanguage
}

class LanguagesTableViewController: ZGTableViewController {
	var rows = [(String, String)]()
	
	var chooseType: LanguageChooseType = .BaseLanguage
	var delegate: LanguagesTableViewControllerDelegate? = nil
	
	var preselectedLanguage: String? = nil
	
	convenience init(chooseType: LanguageChooseType, preselectedLanguage: String? = nil, delegate: LanguagesTableViewControllerDelegate) {
		self.init(style: .Plain)
		
		self.chooseType = chooseType
		self.delegate = delegate
		
		self.preselectedLanguage = preselectedLanguage
		
		self.title = "CHOOSE_LANGUAGE".localized
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(LanguagesTableViewController.setupLanguages), forControlEvents: .ValueChanged)
		self.refreshControl?.beginRefreshing()
		setupLanguages()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (rows.count > 0) {
			tableView.separatorStyle = .SingleLine
			tableView.backgroundView = nil
			return 1
		}
		
		let emptyLabel = UILabel.autoLayoutCapable()
		emptyLabel.text = "NO_LANGUAGES_TO_SHOW".localized
		emptyLabel.numberOfLines = 0
		emptyLabel.textAlignment = .Center
		emptyLabel.sizeToFit()
		
		tableView.backgroundView = emptyLabel
		tableView.separatorStyle = .None
		
		return 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cellTitle = rows[indexPath.row]
		var cell = tableView.dequeueReusableCellWithIdentifier(cellTitle.0)
		if (cell == nil) {
			cell = UITableViewCell(style: .Default, reuseIdentifier: cellTitle.0)
			cell?.textLabel?.text = cellTitle.1
			
			if let preselected = self.preselectedLanguage {
				if preselected == cellTitle.0 {
					cell?.accessoryType = .Checkmark
				}
			}
		}
		
		// Configure the cell...
		
		return cell!
	}
	
	func setupLanguages() {
		let completion: (JSON? -> Void) = { (array) -> Void in
			if let arr = array, langs = arr.rawValue as? [String] {
				var languages: [(String, String)] = []
				
				for l in langs {
					if let ll = LanguagesTableViewController.getNameForLanguageCode(l) {
						languages.append(l, ll)
					} else {
						languages.append(l, l)
					}
				}
				self.rows = languages.sort({ (left, right) -> Bool in
					return left.0 < right.0
				})
			}
			// The CATransaction calls are there to capture the animation of `self.refresher.endRefreshing()`
			// This enables us to attach a completion block to the animation, reloading data before
			// animation is complete causes glitching.
			CATransaction.begin()
			CATransaction.setCompletionBlock({ () -> Void in
				self.tableView.reloadData()
			})
			self.refreshControl?.endRefreshing()
			CATransaction.commit()
		}
		
		switch (chooseType) {
			case .BaseLanguage:
				ZeeguuAPI.sharedAPI().getAvailableNativeLanguages(completion)
				break;
			case .LearnLanguage:
				ZeeguuAPI.sharedAPI().getAvailableLanguages(completion)
				break;
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.delegate?.didChooseLanguage(self.rows[indexPath.row].0, languageType: self.chooseType)
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	static func getNameForLanguageCode(code: String) -> String? {
		return NSLocale.systemLocale().displayNameForKey(NSLocaleLanguageCode, value: code)
	}
	
	static func getEnglishNameForLanguageCode(code: String) -> String? {
		return NSLocale(localeIdentifier: "en-US").displayNameForKey(NSLocaleLanguageCode, value: code)
	}
}

protocol LanguagesTableViewControllerDelegate {
	
	func didChooseLanguage(language: String, languageType: LanguageChooseType)
	
}
