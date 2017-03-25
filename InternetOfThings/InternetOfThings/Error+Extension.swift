//
//  Error+Extension.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/20.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import Foundation
import Alamofire

enum CommonError: Error {
    case unKnownError
    case dataParseError
    case afError(AFError)
    
    var description: String {
        var temp: String
        switch self {
        case .unKnownError:
            temp = "未知错误"
        case .dataParseError:
            temp = "数据解析错误"
        case let .afError(error):
            temp = error.localizedDescription
        }
        return temp
    }
}

class CustomError: Error {
    private(set) var description: String
    
    init(description: String) {
        self.description = description
    }

    static func error(_ error: CommonError) -> CustomError {
        return CustomError(description: error.description)
    }
    
    static func error(_ error: Error?) -> CustomError {
        var ret: CustomError
        if let error = error as? AFError {
            ret = CustomError.error(.afError(error))
        }else if let error = error as? NSError {
            ret = CustomError(description: error.localizedDescription)
        }else {
            ret = CustomError.error(.dataParseError)
        }
        return ret
    }
}
