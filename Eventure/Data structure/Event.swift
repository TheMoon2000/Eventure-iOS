//
//  Event.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event: Codable {
    static var current: Event?
    static var drafts = [Event]()
    
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
    var eventDescription: String
    var eventVisual: UIImage?
    var hostID: String
    var hostTitle: String
    var currentUserGoingStatus: Going = .neutral
    var tags = Set<String>()
    // # of interested, # of going
    // API: array of user id
    
    var published: Bool
    var active: Bool
    
    // MARK: Computed properties
    
    /// A description of the start time of the event.
    var timeDescription: String {
        if startTime != nil {
            return readableFormatter.string(from: startTime!)
        } else {
            return "Unspecified"
        }
    }
    
    /// A description of the duration of the event.
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
    
    /// Returns an empty `Event` object.
    static var empty: Event {
        return Event(uuid: UUID().uuidString,
                     title: "",
                     description: "",
                     startTime: "",
                     endTime: "",
                     location: "",
                     tags: Set<String>(),
                     hostID: Organization.current?.id ?? "<org id>",
                     hostTitle: Organization.current?.title ?? "<Title>")
    }
    
    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case uuid, title, startTime, endTime, location, tags, hostID, hostTitle, description
    }
    
    init(uuid: String, title: String, description: String, startTime: String, endTime: String, location: String, tags: Set<String>, hostID: String, hostTitle: String) {
        self.uuid = uuid
        self.title = title
        self.startTime = DATE_FORMATTER.date(from: startTime)
        self.endTime = DATE_FORMATTER.date(from: endTime)
        self.location = location
        self.tags = tags
        self.hostID = hostID
        self.hostTitle = hostTitle
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
            let org = Organization(orgInfo: hostInfo)
            hostTitle = org.title
            hostID = org.id
        } else {
            hostTitle = "<Title>"
            hostID = "<org id>"
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
    
    func readFromFile(file: String) -> Event? {
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? Data {
            if let decrypted = NSData(data: data).aes256Decrypt(withKey: AES_KEY) {
                return try? PropertyListDecoder().decode(Event.self, from: decrypted)
            } else {
                return nil
            }
        }
        return nil
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        uuid = try values.decode(String.self, forKey: .uuid)
        title = try values.decode(String.self, forKey: .title)
        eventDescription = try values.decode(String.self, forKey: .description)
        location = try values.decode(String.self, forKey: .location)
        startTime = DATE_FORMATTER.date(from: try values.decode(String.self, forKey: .startTime))
        endTime = DATE_FORMATTER.date(from: try values.decode(String.self, forKey: .endTime))
        hostID = try values.decode(String.self, forKey: .hostID)
        hostTitle = try values.decode(String.self, forKey: .hostTitle)
        
        let tags_raw = try values.decode(String.self, forKey: .tags)
        let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
        tags = Set(tagsArray)
        
        active = true
        published = false
        
    }
    
    func writeToFile(path: String) -> Bool {
        let data = try! PropertyListEncoder().encode(self)
        let encrypted = NSData(data: data).aes256Encrypt(withKey: AES_KEY)!
        return NSKeyedArchiver.archiveRootObject(encrypted, toFile: path)
    }
    
    /// Verify whether an event contains all the required information for it to be published. If the event is missing some information, this function will return a non-empty string that describes the requirement.
    func verify() -> String {
        for item in [title, eventDescription, location] {
            if item.isEmpty { return "false" }
        }
        
        if title.isEmpty { return "Event title cannot be blank!" }
        
        if eventDescription.isEmpty {
            return "Event description shouldn't be blank!"
        }
        
        if location.isEmpty {
            return "You did not specify a location for your event."
        }
        
        if startTime == nil || endTime == nil {
            return "You must specify a start time and an end time."
        }
        
        if endTime!.timeIntervalSince(startTime!) <= 0 {
            return "Event end time must come after event start time."
        }
        
        if tags.isEmpty {
            return "You must select 1 - 3 tags to label your event!"
        }
        
        return ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(eventDescription, forKey: .description)
        try container.encode(location, forKey: .location)
        try container.encode(hostID, forKey: .hostID)
        try container.encode(hostTitle, forKey: .hostTitle)
        
        if startTime != nil {
            try container.encode(readableFormatter.string(from: startTime!), forKey: .startTime)
        }
        
        if endTime != nil {
            try container.encode(readableFormatter.string(from: endTime!), forKey: .endTime)
        }
        
        try container.encode(tags.description, forKey: .tags)
    }
    
}


extension Event {
    enum Going: Int {
        case neutral = 0, interested, going
    }
}


extension Event: CustomStringConvertible {
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  uuid = \(uuid)\n"
        str += "  time = \(timeDescription)\n"
        str += "  location = \(location)\n"
        str += "  tags = \(tags.description)"
        
        return str
    }
}
