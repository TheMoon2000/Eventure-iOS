//
//  AdmissionType.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class AdmissionType {
    var typeName: String
    var quota: Int?
    var price: Double?
    var notes: String
    
    var priceDescription: String {
        return String(format: "%.02f", price ?? 0.0)
    }
    
    static var new: AdmissionType {
        return AdmissionType(json: JSON())
    }
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        typeName = dictionary["Name"]?.string ?? ""
        quota = dictionary["Quota"]?.int
        price = dictionary["Price"]?.double
        notes = dictionary["Notes"]?.string ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(typeName)
    }
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["Name"] = typeName
        json.dictionaryObject?["Quota"] = quota
        json.dictionaryObject?["Price"] = price
        json.dictionaryObject?["Notes"] = notes
        return json
    }
}
