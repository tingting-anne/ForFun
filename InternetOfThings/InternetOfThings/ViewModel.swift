//
//  ViewModel.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/17.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct AQIItem {
    let timeInternal: Int64
    let AQl: Int
}

enum LampStatus: String {
    case on = "on", off = "off"
}

class ViewModel {
    
    private let baseURL = "http://106.15.33.105:8001"
    private var lampID: Int?
    private var lampStatus: LampStatus?
    
    func getCurrentAQI(completionHandler: @escaping (Int?, CustomError?) -> Void) {
        let url = baseURL + "/api/aqi"
        
        Alamofire.request(url, method: .get).responseSwiftyJSON {result, error in
            if let resultArray = result.array, let response = resultArray.first, let sum = response["sum"].int, let count = response["count"].int, count > 0 {
                completionHandler(sum/count, nil)
            }else {
                completionHandler(nil, CustomError.error(error))
            }
        }
    }
    
    func getLampStatus(completionHandler: @escaping (LampStatus?, CustomError?) -> Void) {
        let url = baseURL + "/led/status"
        
        Alamofire.request(url, method: .get).responseSwiftyJSON {[weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            
            if let resultArray = result.array,
                let response = resultArray.first,
                let id = response["id"].int,
                let status = response["status"].string,
                let lampStatus = LampStatus(rawValue: status) {
                
                strongSelf.lampID = id
                strongSelf.lampStatus = lampStatus
                completionHandler(lampStatus, nil)
            }else {
                completionHandler(nil, CustomError.error(error))
            }
        }
    }
    
    func changeLampStatus(completionHandler: @escaping (CustomError?) -> Void) {
        guard let lampID = lampID, let lampStatus = lampStatus else {
            completionHandler(CustomError.error(.unKnownError))
            return
        }
        
        let newLampStatus: LampStatus = lampStatus == .on ? .off : .on
        self.lampStatus = newLampStatus
        let url = baseURL + "/api/led"
        let parameters: [String: Any] = ["id": lampID, "action": newLampStatus.rawValue]
     
        Alamofire.request(url, method: .post, parameters: parameters).responseSwiftyJSON {result, error in
            if let result = result["result"].bool {
                completionHandler(result ? nil : CustomError.error(.unKnownError))
            }else {
                completionHandler(CustomError.error(error))
            }
        }
    }
    
    func getHistoryAQI(startTime: String, endTime: String, completionHandler: @escaping ([String]?, [Double]?, CustomError?) -> Void) {
        let url = baseURL + "/api/air"
        let parameters: [String: Any] = ["st": startTime, "et": endTime, "precision": "day", "id": 1]
        
        Alamofire.request(url, method: .get, parameters: parameters).responseSwiftyJSON {result, error in
            if let timeArray = result["x"].arrayObject as? [String],
                let aqiArray = result["y"].arrayObject as? [Double] {
                completionHandler(timeArray, aqiArray, nil)
            }else {
                completionHandler(nil, nil, CustomError.error(error))
            }
        }
    }
}
