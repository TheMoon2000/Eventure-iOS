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
        formatter.dateFormat = "E, d MMM yyyy H:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    var uuid: String
    var title: String
    var location: String
    var time: Date?
    var timeDescription: String {
        if time != nil {
            return readableFormatter.string(from: time!)
        } else {
            return "Unspecified"
        }
    }
    var eventDescription: String
    var eventVisual: UIImage?
    var host: Organization?
    var hostName: String {
        return host?.title ?? hostDescription
    }
    private var hostDescription = ""
    var attendees = [User]()
    var tags = [String]()
    // # of interested, # of going
    // API: array of user id
    
    var active: Bool
    
    init(uuid: String, title: String, time: String, location: String, tags: [String], hostTitle: String) {
        self.uuid = uuid
        self.title = title
        self.time = DATE_FORMATTER.date(from: time)
        self.location = location
        self.tags = tags
        self.hostDescription = hostTitle
        self.active = true
        //eventVisual = nil
        eventDescription = "test"
    }
    
    init(eventInfo: JSON) {
        let dictionary = eventInfo.dictionary!
        
        uuid = dictionary["ID"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        location = dictionary["Location"]?.string ?? ""
        if let timeString = dictionary["Time"]?.string {
            self.time = DATE_FORMATTER.date(from: timeString)
        }
        eventDescription = dictionary["Description"]?.string ?? ""
        //eventDescription = dictionary["Description"]?.string ?? ""
        if let hostInfo = dictionary["Organization"] {
            host = Organization(orgInfo: hostInfo)
        } else {
            hostDescription = "Unknown"
        }
        
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
            tags = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
        } else {
            tags = [String]()
        }
        
        
        active = (dictionary["Active"]?.int ?? 1) == 1
    }
    
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  uuid = \(uuid)\n"
        str += "  time = \(timeDescription)\n"
        str += "  @ = \(location)\n"
        str += "  tags = \(tags.description)"
        
        return str
    }
    
}

