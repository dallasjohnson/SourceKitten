//
//  SwiftXPC+JSON.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-06.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation
import SwiftXPC

public typealias SourceKitRepresentable = XPCRepresentable

/**
JSON Object to JSON String.

- parameter object: Object to convert to JSON.

- returns: JSON string representation of the input object.
*/
public func toJSON(object: AnyObject) -> String {
    do {
        let prettyJSONData = try NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted)
        if let jsonString = NSString(data: prettyJSONData, encoding: NSUTF8StringEncoding) as? String {
            return jsonString
        }
    } catch {}
    return ""
}

/**
Convert [String: SourceKitRepresentable] to `[String: AnyObject]`.

- parameter dictionary: [String: SourceKitRepresentable] to convert.

- returns: JSON-serializable Dictionary.
*/
public func toAnyObject(dictionary: [String: SourceKitRepresentable]) -> [String: AnyObject] {
    var anyDictionary = [String: AnyObject]()
    for (key, object) in dictionary {
        switch object {
        case let object as AnyObject:
            anyDictionary[key] = object
        case let object as [SourceKitRepresentable]:
            anyDictionary[key] = object.map { toAnyObject($0 as! [String: SourceKitRepresentable]) }
        case let object as [[String: SourceKitRepresentable]]:
            anyDictionary[key] = object.map { toAnyObject($0) }
        case let object as [String: SourceKitRepresentable]:
            anyDictionary[key] = toAnyObject(object)
        case let object as String:
            anyDictionary[key] = object
        case let object as NSDate:
            anyDictionary[key] = object
        case let object as NSData:
            anyDictionary[key] = object
        case let object as UInt64:
            anyDictionary[key] = NSNumber(unsignedLongLong: object)
        case let object as Int64:
            anyDictionary[key] = NSNumber(longLong: object)
        case let object as Double:
            anyDictionary[key] = NSNumber(double: object)
        case let object as Bool:
            anyDictionary[key] = NSNumber(bool: object)
        case let object as NSFileHandle:
            anyDictionary[key] = NSNumber(int: object.fileDescriptor)
        default:
            fatalError("Should never happen because we've checked all SourceKitRepresentable types")
        }
    }
    return anyDictionary
}
