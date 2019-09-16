//
//  Ticket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Ticket {
    
    var ticketID: String
    var userID: Int
    var eventID: String
    var eventName: String
    var hostName: String
    var hostID: String
    var transactionDate: Date?
    
    var orgLogo: UIImageView?
    
    required init(ticketInfo: JSON) {
        let dictionary = ticketInfo.dictionaryValue
        
        ticketID = dictionary["Ticket ID"]?.string ?? ""
        userID = dictionary["User ID"]?.int ?? -1
        eventID = dictionary["Event ID"]?.string ?? ""
        eventName = dictionary["Event title"]?.string ?? ""
        hostName = dictionary["Organization title"]?.string ?? ""
        hostID = dictionary["Organization"]?.string ?? ""
        
        if let dateString = dictionary["Transaction date"]?.string {
            transactionDate = DATE_FORMATTER.date(from: dateString)
        }
        
    }
}
