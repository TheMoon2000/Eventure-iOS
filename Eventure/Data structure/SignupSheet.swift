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
    let name: String
    let capacity: Int
    var currentOccupied: Int
    var currentUserCheckedIn: Bool
    var createdDate: Date
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        uuid = dictionary["uuid"]?.string ?? ""
        orgID = dictionary["Organization"]?.string ?? ""
        name = dictionary["List name"]?.string ?? "Online Check-in"
        capacity = dictionary["Capacity"]?.int ?? 0
        
        if let dateString = dictionary["Created date"]?.string {
            createdDate = DATE_FORMATTER.date(from: dateString) ?? Date(timeIntervalSinceReferenceDate: 0)
        } else {
            createdDate = Date(timeIntervalSinceReferenceDate: 0)
        }
        
        currentOccupied = dictionary["Occupied"]?.int ?? 0
        currentUserCheckedIn = dictionary["Checked in"]?.bool ?? false
    }
    
}
