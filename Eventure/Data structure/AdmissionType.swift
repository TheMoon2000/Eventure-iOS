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
    
    /// The ID is immutable.
    let id: String
    var eventID: String
    var typeName: String
    var quota: Int? // Either 0 or nil means no quota
    var price: Double? // Should not be nil unless just initialized
    var notes: String
    
    var currentRevenue: Double
    var quantitySold: Int
    
    var priceDescription: String {
        return String(format: "%.02f", price ?? 0.0)
    }
    
    init(eventID: String) {
        self.id = UUID().uuidString.lowercased()
        self.typeName = ""
        self.eventID = eventID
        self.notes = ""
        currentRevenue = 0.0
        quantitySold = 0
    }
    
    init(json: JSON, admissionID: String, eventID: String) {
        let dictionary = json.dictionaryValue
        
        self.id = admissionID
        self.eventID = eventID
        typeName = dictionary["Type name"]?.string ?? ""
        quota = dictionary["Quota"]?.int
        price = dictionary["Price"]?.double
        notes = dictionary["Notes"]?.string ?? ""
        currentRevenue = dictionary["Revenue"]?.double ?? 0.0
        quantitySold = dictionary["Quantity"]?.int ?? 0
    }
    
    /// Encodes everything but the ID.
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["Type name"] = typeName
        json.dictionaryObject?["Quota"] = quota
        json.dictionaryObject?["Price"] = price
        json.dictionaryObject?["Notes"] = notes
        json.dictionaryObject?["Quantity"] = quantitySold
        
        // The revenue should not be saved
        
        return json
    }
    
}

extension AdmissionType: Hashable {
    static func ==(lhs: AdmissionType, rhs: AdmissionType) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
