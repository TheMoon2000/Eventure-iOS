//
//  AccountNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountNotification {
    let userID: Int
    let title: String
    var creationDate: Date?
    let rawContent: JSON
    let type: ContentType
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        self.userID = dictionary["User ID"]?.int ?? -1
        self.title = dictionary["Title"]?.string ?? ""
        if let dateRaw = dictionary["Date"]?.string {
            creationDate = PRECISE_FORMATTER.date(from: dateRaw)
        }
        if let typeRaw = dictionary["Type"]?.string {
            type = ContentType(rawValue: typeRaw) ?? .plain
        } else {
            type = .plain
        }
        self.rawContent = dictionary["Content"]!
    }
    
    static func new(json: JSON) -> AccountNotification? {
        let dictionary = json.dictionaryValue
        guard let typeString = dictionary["Type"]?.string else { return nil }
        let type = ContentType(rawValue: typeString)
        switch type {
        case .event:
            return EventNotification(json: json)
        default:
            return AccountNotification(json: json)
        }
    }
    
    enum ContentType: String {
        case plain = "PLAIN"
        case event = "EVENT"
        case eventUpdate = "EVENT UPDATE"
        case newTicket = "NEW TICKET"
    }
}
