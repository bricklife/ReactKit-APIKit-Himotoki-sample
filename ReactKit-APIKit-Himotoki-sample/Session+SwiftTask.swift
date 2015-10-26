//
//  Session+SwiftTask.swift
//  ReactKit-APIKit-Himotoki-sample
//
//  Created by Shinichiro Oba on 2015/10/06.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

import Foundation
import APIKit
import SwiftTask

extension Session {
    static func taskFromRequest<T: RequestType>(request: T) -> Task<Void, T.Response, ErrorType> {
        return Task { fulfill, reject in
            self.sendRequest(request) { result in
                switch result {
                case .Success(let response):
                    fulfill(response)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }
}