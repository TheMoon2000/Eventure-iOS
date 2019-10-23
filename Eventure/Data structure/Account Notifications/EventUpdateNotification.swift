//
//  EventUpdateNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// A subclass of user account notifications that presents an event update.
class EventUpdateNotification: AccountNotification {
    var updateType: UpdateType = .none
    var eventID = ""
    var eventTitle = ""
    var updateValue = ""
    var message = ""
    
    override var type: AccountNotification.ContentType {
        return .eventUpdate
    }
    
    override var shortString: String {
        switch updateType {
        case .none:
            return "There was an error loading this message."
        case .location:
            return "The location for \(eventTitle) has been changed to **\(updateValue)**."
        case .startTime:
            return "The starting time for \(eventTitle) has been changed to **\(updateValue)**."
        }
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.eventID = rawContent.dictionary?["eventId"]?.string ?? ""
        self.eventTitle = rawContent.dictionary?["eventTitle"]?.string ?? ""
        if let startTime = rawContent.dictionary?["startTime"]?.string {
            self.updateType = .startTime
            if let date = DATE_FORMATTER.date(from: startTime) {
                updateValue = date.readableString()
            }
        } else if let location = rawContent.dictionary?["newLocation"]?.string {
            self.updateType = .location
            updateValue = location
        }
    }
    
    enum UpdateType: String {
        case startTime = "startTime"
        case location = "location"
        case none = ""
    }
}
