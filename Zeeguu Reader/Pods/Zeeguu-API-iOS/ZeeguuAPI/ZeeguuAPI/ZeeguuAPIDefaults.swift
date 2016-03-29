//
//  ZeeguuDefaults.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 28-11-15.
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

/// This global variable is used by the `showNetworkIndicator` function. The `showNetworkIndicator` function is called with parameter `show` being `true` once a request starts and called again with `show` being `false` once a request finished.
///
/// The iOS API Framework only allows the set the network activity indicator visible or hidden. This variable was created to indicate how many requests/network activities are currently active. The `showNetworkIndicator` function decrements (if `show` is `false`) this variable and only hides the network activity indicator once this variable reaches zero.
///
/// The function increments this variable if `show` is `true`.
var networkActivityCounter = 0;

extension ZeeguuAPI {
	static let apiHost: String = "https://zeeguu.unibe.ch"
	static let sessionIDKey: String = "ZeeguuSessionID"
	
	func requestWithEndPoint(endPoint: ZeeguuAPIEndpoint, pathComponents: Array<String>? = nil, method: HTTPMethod, parameters: Dictionary<String, String>? = nil, jsonBody: JSON? = nil) -> NSURLRequest {
		var path: NSString = NSString(string: ZeeguuAPI.apiHost).stringByAppendingPathComponent(endPoint.rawValue)
		
		// Add pathcomponent to the host if there are any (for example, adding <email> to host/add_user: host/add_user/<email>)
		if (pathComponents != nil) {
			for pathComponent in pathComponents! {
				path = path.stringByAppendingPathComponent(pathComponent.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!);
			}
		}
		
		// Append session id to url if we have one
		var delimiter = "?"
		if (self.isLoggedIn) {
			path = path.stringByAppendingString("?session=" + String(self.currentSessionID))
			delimiter = "&"
		}
		
		// Convert the parameters (if any) to a string of the form "key1=value1&key2=value2"
		var params = ""
		if (parameters != nil) {
			params = self.httpQueryStringForDictionary(parameters!)
		}
		
		// Add parameters to url if method is GET or jsonBody is not nil
		if ((method == HTTPMethod.GET || jsonBody != nil) && params.characters.count > 0) {
			path = path.stringByAppendingString(delimiter + params)
		}
		
		// Create request with the url
		let url = NSURL(string: path as String)
		let request = NSMutableURLRequest(URL: url!)
		
		// Set request to be POST (if method is POST) and add the parameters to the request
		if (method == HTTPMethod.POST) {
			request.HTTPMethod = method.rawValue
			request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
			request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField:"Content-Type");
			if (self.enableDebugOutput) {
				print("httpbody: \(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)))")
			}
		}
		
		// If jsonBody != nil, overwrite http body with json data
		if let jsonString = jsonBody {
			var requestData: NSData?
			if let str = jsonString.rawString() {
				requestData = str.dataUsingEncoding(NSUTF8StringEncoding)
			} else {
				requestData = "".dataUsingEncoding(NSUTF8StringEncoding)
			}
			
			var requestDataLength: String
			if let length = requestData?.length {
				requestDataLength = (length as NSNumber).stringValue
			} else {
				requestDataLength = "0"
			}
			request.HTTPBody = requestData
			request.setValue("application/json", forHTTPHeaderField: "Content-Type");
			request.setValue(requestDataLength, forHTTPHeaderField: "Content-Length")
		}
		
		return request
	}
	
	func httpQueryStringForDictionary(dict: Dictionary<String, String>) -> String {
		var arr = [String]()
		
		for (key, value) in dict {
			arr.append(key + "=" + value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
		}
		return arr.joinWithSeparator("&")
	}
	
	func sendAsynchronousRequest(request: NSURLRequest, completion: (response: String?, error: NSError?) -> Void) {
		let session = NSURLSession.sharedSession()
		debugPrint("Sending request for url \"\(request.URL)\": \(request)\n\n");
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			self.debugPrint("Entered dataTaksWithRequest completion block: data: \(data), response: \(response), error: \(error)");
			if (data != nil && response != nil && (response! as! NSHTTPURLResponse).statusCode == 200) {
				let response = String(data: data!, encoding: NSUTF8StringEncoding)!
				self.debugPrint("Response from url \"\(request.URL)\": \(response)\n\n");
				completion(response: response, error: nil)
			} else {
				if (response != nil) {
					self.debugPrint("Response object for url \"\(request.URL)\": \(response)\n\n");
				}
				if (error != nil) {
					self.debugPrint("Error for url \"\(request.URL)\": \(error)\n\n");
				}
				completion(response: nil, error: error)
			}
			self.showNetworkIndicator(false)
		}
		task.resume()
		self.showNetworkIndicator(true)
	}
	
	func write500ErrorToLog(request: NSURLRequest, data: NSData?, response: NSURLResponse?, error: NSError?) {
		let file = "500Erros.log" //this is the file. we will write to and read from it
		
		var text = "\n\n\nDate: \(NSDate())\n\nSent request for url \"\(request.URL)\": \(request)\n\n" //just a text
		
		text += "Server response:\n\ndata: \(data)\n\nresponse: \(response)\n\nerror: \(error)\n\n"
		
		if let dat = data {
			text += "Server response as text: \(NSString(data: dat, encoding: NSUTF8StringEncoding))\n\n\n"
		}
		if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
			let path = dir.stringByAppendingPathComponent(file);
			
			//writing
			do {
				if (NSFileManager.defaultManager().fileExistsAtPath(path)) {
					if let textData = text.dataUsingEncoding(NSUTF8StringEncoding),
						fileHandle = NSFileHandle(forWritingAtPath: path) {
							fileHandle.seekToEndOfFile()
							fileHandle.writeData(textData)
							fileHandle.closeFile()
					}
				} else {
					try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
				}
				
				
			}
			catch {/* error handling here */}
		}
	}
	
	func sendAsynchronousRequestWithDataResponse(request: NSURLRequest, completion: (data: NSData?, error: NSError?) -> Void) {
		let session = NSURLSession.sharedSession()
		debugPrint("Sending request for url \"\(request.URL)\": \(request)\n\n");
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			self.debugPrint("Entered dataTaksWithRequest completion block: data: \(data), response: \(response), error: \(error)");
			
			if let d = data, r = response as? NSHTTPURLResponse where r.statusCode == 200 {
				completion(data: d, error: nil)
			} else if let r = response as? NSHTTPURLResponse where r.statusCode == 500 {
				self.write500ErrorToLog(request, data: data, response: response, error: error)
				completion(data: nil, error: error)
			} else {
				if let r = response {
					self.debugPrint("Response object for url \"\(request.URL)\": \(r)\n\n");
				}
				if let err = error {
					self.debugPrint("Error for url \"\(request.URL)\": \(err)\n\n");
				}
				completion(data: nil, error: error)
			}
			self.showNetworkIndicator(false)
		}
		task.resume()
		self.showNetworkIndicator(true)
	}
	
	func checkIfLoggedIn() -> Bool {
		if (!self.isLoggedIn) {
			print("There is no user logged in currently!")
			return false
		}
		return true
	}
	
	func checkBooleanResponse(response: String?, error: NSError?, completion: (success: Bool) -> Void) {
		if (response != nil && response == "OK") {
			completion(success: true)
		} else {
			completion(success: false)
		}
	}
	
	func checkJSONResponse(response: String?, error: NSError?, completion: (dict: JSON?) -> Void) {
		if (response != nil) {
			completion(dict: JSON.parse(response!))
		} else {
			completion(dict: nil)
		}
	}
	
	func checkStringResponse(response: String?, error: NSError?, completion: (string: String?) -> Void) {
		debugPrint("repsonse: \(response)")
		if (response != nil) {
			completion(string: response!)
		} else {
			completion(string: nil)
		}
	}
	
	/// This function shows a network activity indicator. The network activity indicator is a small spinner in the status bar of the iPhone/iPad (where also the carrier, time, battery status etc. are displayed).
	///
	/// See also `networkActivityCounter`.
	///
	/// - parameter show: Indicates whether to show or hide the network activity indicator.
	func showNetworkIndicator(show: Bool) {
		if (show) {
			networkActivityCounter += 1
		} else {
			networkActivityCounter -= 1
			if (networkActivityCounter < 0) {
				networkActivityCounter = 0
			}
		}
		if (networkActivityCounter <= 0) {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		} else {
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		}
	}
	
	func debugPrint(text: String) {
		if (self.enableDebugOutput) {
			print(text)
		}
	}
}