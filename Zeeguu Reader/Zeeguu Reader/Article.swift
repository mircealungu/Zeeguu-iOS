//
//  Article.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit

class Article {
	var source: String
	var title: String
	var url: String
	var date: String
	var contents: String?
	
	init(articleTitle: String, articleUrl: String, articleDate: String, articleSource: String) {
		source = articleSource;
		title = articleTitle;
		url = articleUrl;
		date = articleDate;
	}
}
