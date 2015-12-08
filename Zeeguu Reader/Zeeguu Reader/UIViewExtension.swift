//
//  UIViewExtension.swift
//  Zeeguu Reader
//
//  Created by Jorrit Oosterhof on 08-12-15.
//  Copyright © 2015 Jorrit Oosterhof. All rights reserved.
//

import UIKit

extension UIView {
	
	/// Returns an instance of (subclass of) UIView that has its `translatesAutoresizingMaskIntoConstraints` property set to false
	static func autoLayoutCapapble() -> Self {
		let instance = self.init()
		instance.translatesAutoresizingMaskIntoConstraints = false
		return instance
	}
	
}
