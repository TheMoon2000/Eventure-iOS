//
//  TicketRequest.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class TicketRequest {
    
    var username: String
    var userID: Int
    var email: String
    var eventID: String
    var admissionID: String
    var requestDate: Date?
    var quantity: Int
    var notes: String
    var status: Status
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        username = dictionary["Displayed name"]?.string ?? ""
        if username.isEmpty {
            username = dictionary["Full name"]?.string ?? ""
        }
        userID = dictionary["User ID"]?.int ?? -1
        email = dictionary["Email"]?.string ?? ""
        eventID = dictionary["Event ID"]?.string ?? ""
        admissionID = dictionary["Admission ID"]?.string ?? ""
        if let dateString = dictionary["Request date"]?.stringValue {
            requestDate = DATE_FORMATTER.date(from: dateString)
        }
        quantity = dictionary["Quantity"]?.int ?? 1
        notes = dictionary["Notes"]?.string ?? ""
        status = Status(rawValue: (dictionary["Status"]?.int ?? 0)) ?? .pending
    }
}

extension TicketRequest {
    enum Status: Int {
        case declined = -1
        case approved = 1
        case pending = 0
    }
}
