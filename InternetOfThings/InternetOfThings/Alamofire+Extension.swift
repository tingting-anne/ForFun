//
//  Alamofire+Extension.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/20.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension Alamofire.DataRequest {
    
    @discardableResult
    public func responseSwiftyJSON(_ completionHandler: @escaping (JSON, Error?) -> Void) -> Self {
        
        return responseJSON { response in
            var responseJSON: JSON
            var responseError: Error?
            
            switch response.result{
            case .success(let object):
                responseJSON = JSON(object)
            case .failure(let error):
                responseError = error
                responseJSON = JSON.null
            }
            
            completionHandler(responseJSON, responseError)
        }
    }
}

