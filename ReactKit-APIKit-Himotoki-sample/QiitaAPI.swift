//
//  QiitaAPI.swift
//  ReactKit-APIKit-Himotoki-sample
//
//  Created by Shinichiro Oba on 2015/10/06.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

import Foundation
import APIKit
import Himotoki

protocol QiitaRequest: RequestType {
}

extension QiitaRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://qiita.com/api/v2")!
    }
}

struct GetItemsRequest: QiitaRequest {
    typealias Response = [Item]
    
    let query: String
    
    init(query: String) {
        self.query = query
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var path: String {
        return "/items"
    }
    
    var parameters: [String: AnyObject] {
        return [
            "page": "1",
            "per_page": "20",
            "query": self.query,
        ]
    }
    
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        return try? decodeArray(object)
    }
}

struct Item: Decodable {
    let title: String
    let createdAt: NSDate
    let url: NSURL
    let userId: String
    
    static func decode(e: Extractor) throws -> Item {
        return try build(self.init)(
            e <| "title",
            dateFromString(e <| "created_at"),
            e <| "url",
            e <| ["user", "id"]
        )
    }
    
    private static func dateFromString(string: String) throws -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let result = dateFormatter.dateFromString(string) else {
            throw ConvertError.InvalidParameter(type: "\(self)", from: string)
        }
        
        return result
    }
}

extension NSURL: Decodable {
    public static func decode(e: Extractor) throws -> NSURL {
        let rawValue = try String.decode(e)
        
        guard let result = NSURL(string: rawValue) else {
            throw ConvertError.InvalidParameter(type: "\(self)", from: rawValue)
        }
        
        return result
    }
}

public enum ConvertError: ErrorType {
    case InvalidParameter(type: String, from: String)
}
