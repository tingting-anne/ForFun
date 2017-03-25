//
//  DateAxisValueFormatter.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/16.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import Foundation
import Charts

class DateAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "MM/dd"
    }
    
    func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date.init(timeIntervalSince1970: value))
    }
}
