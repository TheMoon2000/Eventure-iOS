//
//  SignupSheet.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignupSheet {
    
    let uuid: String
    let orgID: String
    var name: String
    var capacity: Int
    var registrants = [Int: Date]()
    var createdDate: Date
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        uuid = dictionary["uuid"]?.string ?? ""
        orgID = dictionary["Organization"]?.string ?? ""
        name = dictionary["List name"]?.string ?? ""
        capacity = dictionary["Capacity"]?.int ?? 0
        
        if let regData = dictionary["Registrants"]?.string {
            for reg in JSON(parseJSON: regData).dictionaryValue {
                registrants[Int(reg.key) ?? -1] = DATE_FORMATTER.date(from: reg.value.stringValue)
            }
        }
        
        if let dateString = dictionary["Created date"]?.string {
            createdDate = DATE_FORMATTER.date(from: dateString) ?? Date(timeIntervalSinceReferenceDate: 0)
        } else {
            createdDate = Date(timeIntervalSinceReferenceDate: 0)
        }
    }
    
}
