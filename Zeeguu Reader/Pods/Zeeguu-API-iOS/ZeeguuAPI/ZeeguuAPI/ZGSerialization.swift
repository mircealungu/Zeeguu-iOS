//
//  ZGSerialization.swift
//  ZeeguuAPI
//
//  Created by Jorrit Oosterhof on 22-06-16.
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

/**
This protocol dictates some methods for easy converting between object and dictionary representation.
*/
@objc public protocol ZGSerializable {
	
	/**
	Construct a new object from the data in the dictionary.
	
	- parameter dictionary: The dictionary that contains the data from which to construct an object.
	*/
	init?(dictionary dict: [String: AnyObject])
	
	
	/**
	The dictionary representation of this object.
	
	- returns: A dictionary that contains all data of this object.
	*/
	func dictionaryRepresentation() -> [String: AnyObject]
	
}

/**
This class offers some convenience methods for easy converting between arrays of `ZGSerialization` objects and dictionary representations.
*/
public class ZGSerialize {
	
	/**
	The array of dictionary representations of an array with objects conforming to `ZGSerialization`.
	
	- parameter array: The array of objects to encode.
	- returns: An array of dictionaries that represent the objects in `array`.
	*/
	public static func encodeArray(array: [ZGSerializable]) -> [[String: AnyObject]] {
		var arr = [[String: AnyObject]]()
		for item in array {
			arr.append(encodeObject(item))
		}
		return arr
	}
	
	/**
	The array of objects given by the array ofdictionary representations.
	
	- parameter array: The array of dictionaries to decode.
	- returns: An array of objects that were constructed from the dictionaries with the given type `T`.
	*/
	public static func decodeArray(array: [[String: AnyObject]]) -> [ZGSerializable] {
		var arr = [ZGSerializable]()
		
		for item in array {
			if let obj = decodeObject(item) {
				arr.append(obj)
			}
		}
		
		return arr
	}
	
	/**
	The array of dictionary representations of an array with objects conforming to `ZGSerialization`.
	
	- parameter array: The array of objects to encode.
	- returns: An array of dictionaries that represent the objects in `array`.
	*/
	public static func encodeObject(object: ZGSerializable) -> [String: AnyObject] {
		var dict = object.dictionaryRepresentation()
		
		for (key, value) in dict {
			if let value = value as? ZGSerializable {
				dict[key] = encodeObject(value)
			}
		}
		
		dict["____class"] = NSStringFromClass(object.dynamicType)
		
		return dict
	}
	
	/**
	The array of objects given by the array ofdictionary representations.
	
	- parameter array: The array of dictionaries to decode.
	- returns: An array of objects that were constructed from the dictionaries with the given type `T`.
	*/
	public static func decodeObject(dict: [String: AnyObject]) -> ZGSerializable? {
		var dict = dict
		
		for (key, value2) in dict {
			if let value = value2 as? [String: AnyObject], clsStr = value["____class"] as? String, cls = NSClassFromString(clsStr) as? ZGSerializable.Type, obj = cls.init(dictionary: value) {
				dict[key] = obj
			}
		}
		
		if let clsStr = dict["____class"] as? String, cls = NSClassFromString(clsStr) as? ZGSerializable.Type, obj = cls.init(dictionary: dict) {
			return obj
		}
		return nil
	}
	
}