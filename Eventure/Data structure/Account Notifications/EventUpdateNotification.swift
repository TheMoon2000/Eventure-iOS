//
//  EventUpdateNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import BonMot

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
    
    override var shortString: NSAttributedString {
                
        let valuePart = updateValue.styled(with: .valueStyle)
        
        switch updateType {
        case .none:
            return "There was an error loading this message.".styled(with: .basicStyle)
        case .location:
            let part1 = "The location for \(eventTitle) has been changed to ".styled(with: .basicStyle)
            let part3 = ".".styled(with: .basicStyle)
            return NSAttributedString.composed(of: [part1, valuePart, part3])
        case .startTime:
            let part1 = "The starting time for \(eventTitle) has been changed to ".styled(with: .basicStyle)
            let part3 = ".".styled(with: .basicStyle)
            return NSAttributedString.composed(of: [part1, valuePart, part3])
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
        } else {
            print("read update error: \(rawContent)")
        }
    }
    
    enum UpdateType: String {
        case startTime = "startTime"
        case location = "location"
        case none = ""
    }
}
