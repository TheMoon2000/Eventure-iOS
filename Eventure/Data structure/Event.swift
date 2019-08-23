//
//  Event.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event: CustomStringConvertible {
    static var current: Event?
    
    let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    let uuid: String
    var title: String
    var location: String
    var startTime: Date?
    var endTime: Date?
    var timeDescription: String {
        if startTime != nil {
            return readableFormatter.string(from: startTime!)
        } else {
            return "Unspecified"
        }
    }
    var duration: String {
        let dc = DateComponentsFormatter()
        dc.allowedUnits = [.month, .weekOfMonth, .day, .hour, .minute]
        dc.zeroFormattingBehavior = .dropLeading
        dc.maximumUnitCount = 2
        dc.unitsStyle = .full
        
        if startTime != nil && endTime != nil {
            return dc.string(from: endTime!.timeIntervalSince(startTime!))!
        } else {
            return "TBD"
        }
    }
    var eventDescription: String
    var eventVisual: UIImage?
    var host: Organization?
    var hostName: String {
        return host?.title ?? "Unknown"
    }
    var currentUserGoingStatus: Going = .neutral
    var tags = Set<String>()
    // # of interested, # of going
    // API: array of user id
    
    var published: Bool
    var active: Bool
    
    static var empty: Event {
        return Event(uuid: UUID().uuidString, title: "", time: "", location: "", tags: [], host: Organization.current)
    }
    
    init(uuid: String, title: String, description: String, time: String, location: String, tags: Set<String>, host: Organization? = nil) {
        self.uuid = uuid
        self.title = title
        self.startTime = DATE_FORMATTER.date(from: time)
        self.location = location
        self.tags = tags
        self.host = host
        self.active = true
        self.published = false
        self.eventDescription = description
    }
    
    init(eventInfo: JSON) {
        let dictionary = eventInfo.dictionary!
        
        uuid = dictionary["uuid"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        location = dictionary["Location"]?.string ?? ""
        if let startTimeString = dictionary["Start time"]?.string {
            self.startTime = DATE_FORMATTER.date(from: startTimeString)
        }
        if let endTimeString = dictionary["End time"]?.string {
            self.endTime = DATE_FORMATTER.date(from: endTimeString)
        }
        eventDescription = dictionary["Description"]?.string ?? ""
        //eventDescription = dictionary["Description"]?.string ?? ""
        if let hostInfo = dictionary["Organization"] {
            host = Organization(orgInfo: hostInfo)
        } else {
            hostDescription = "Unknown"
        }
        
        published = (dictionary["Published"]?.int ?? 0) == 1
        
        /*let attendees_raw = { () -> [String] in
         var attendees_arr = [String]()
         for a in attendees {
         attendees_arr.append(a.email)
         }
         return attendees_arr
         }()
         
         if let attendees_raw = dictionary["Attendees"]?.string {
         let attendees_Email = (JSON(parseJSON: attendees_raw).arrayObject as? [String]) ?? [String]()
         }*/
        
        if let tags_raw = dictionary["Tags"]?.string {
            let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
            tags = Set(tagsArray)
        } else {
            tags = []
        }
        
        if let going_raw = dictionary["Going"]?.int {
            currentUserGoingStatus = Going(rawValue: going_raw) ?? .neutral
        }
        
        active = (dictionary["Active"]?.int ?? 1) == 1
    }
    
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  uuid = \(uuid)\n"
        str += "  time = \(timeDescription)\n"
        str += "  location = \(location)\n"
        str += "  tags = \(tags.description)"
        
        return str
    }
    
}

extension Event {
    enum Going: Int {
        case neutral = 0, interested, going
    }
}

