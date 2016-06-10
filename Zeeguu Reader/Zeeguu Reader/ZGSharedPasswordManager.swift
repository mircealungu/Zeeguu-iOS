//
//  ZGSharedPasswordManager.swift
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

class ZGSharedPasswordManager: NSObject {

	private static let domain: CFString = "zeeguu.unibe.ch"
	
	static func retrieveSharedCredentials(completion: (email: String?, password: String?) -> Void) {
		SecRequestSharedWebCredential(nil, nil) { (credentials: CFArray?, error: CFError?) in
			var email: String?
			var password: String?
			if let err = error {
				print("Could not retrieve credentials, error: \(err)")
			} else if let cred: NSArray = credentials where cred.count > 0 {
				if let credential = cred[0] as? [String: String] {
					email = credential[kSecAttrAccount as String]
					password = credential[kSecSharedPassword as String]
				}
			}
			
			dispatch_async(dispatch_get_main_queue(), { 
				completion(email: email, password: password)
			})
		}
	}
	
	static func updateSharedCredentials(email: NSString, password: NSString) {
		SecAddSharedWebCredential(self.domain, email, password.length > 0 ? password : nil) { (error: CFError?) in
			if let err = error {
				print("Updating credemtials failed: \(err)")
			}
		}
	}
	
}
