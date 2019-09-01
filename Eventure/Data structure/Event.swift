//
//  Event.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event {
    static var current: Event?
    static var drafts = [Event]()
    static var supportedCampuses = [String : String]()
    
    private static var cachedEvents = [String: [[String: Any]]]()

    let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    var uuid: String
    var title: String
    var location: String
    var startTime: Date?
    var endTime: Date?
    var eventDescription: String
    var eventVisual: UIImage?
    var hasVisual = false
    var hostID: String
    var hostTitle: String
    var currentUserInterested: Bool {
        return User.current != nil && User.current!.interestedEvents.contains(uuid)
    }
    var currentUserFavorited: Bool {
        return User.current != nil && User.current!.favoritedEvents.contains(uuid)
    }
    var tags = Set<String>()
    // API: array of user id
    
    var published: Bool
    var active: Bool
    
    // MARK: Computed properties
    
    /// A description of the start time of the event.
    var timeDescription: String {
        if startTime != nil {
            if YEAR_FORMATTER.string(from: Date()) != YEAR_FORMATTER.string(from: startTime!) {
                return readableFormatter.string(from: startTime!)
            } else {
                return shortFormatter.string(from: startTime!)
            }
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
            return "TBA"
        }
    }
    
    /// Returns an empty `Event` object.
    static var empty: Event {
        return Event(uuid: UUID().uuidString.lowercased(),
                     title: "",
                     description: "",
                     startTime: "",
                     endTime: "",
                     location: "",
                     tags: Set<String>(),
                     hostID: Organization.current?.id ?? "",
                     hostTitle: Organization.current?.title ?? "Untitled")
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
        location = dictionary["Location"]?.string ?? "TBA"
        
        if let startTimeString = dictionary["Start time"]?.string {
            self.startTime = DATE_FORMATTER.date(from: startTimeString)
        }
        
        if let endTimeString = dictionary["End time"]?.string {
            self.endTime = DATE_FORMATTER.date(from: endTimeString)
        }
        
        eventDescription = dictionary["Description"]?.string ?? ""
        hostTitle = dictionary["Organization title"]?.string ?? "Untitled"
        hostID = dictionary["Organization"]?.string ?? ""
        
        published = (dictionary["Published"]?.int ?? 0) == 1
        
        if let tags_raw = dictionary["Tags"]?.string {
            if let tagsArray = JSON(parseJSON: tags_raw).arrayObject as? [String] {
                tags = Set(tagsArray)
            }
        }
        
        active = (dictionary["Active"]?.int ?? 1) == 1
        hasVisual = dictionary["Has cover"]?.bool ?? false
        
        guard let user = User.current else {
            return
        }
        
        if let isInterested = dictionary["Is interested"]?.bool {
            if isInterested && !user.interestedEvents.contains(uuid) {
                user.interestedEvents.insert(uuid)
            } else if !isInterested && user.interestedEvents.contains(uuid) {
                User.current?.interestedEvents.remove(uuid)
            }
        }
        
        if let isFavorited = dictionary["Is favorited"]?.bool {
            if isFavorited && !user.favoritedEvents.contains(uuid) {
                user.favoritedEvents.insert(uuid)
            } else if !isFavorited && user.favoritedEvents.contains(uuid) {
                user.favoritedEvents.remove(uuid)
            }
        }
    }
    
    static func readFromFile(path: String) -> [String: Set<Event>] {
        
        var events = [String: Set<Event>]()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            return [:] // It's fine if no event collection cache exists.
        }
        
        guard let collection = fileData as? [String: [[String: Any]]] else {
            print("WARNING: Cannot read event collection at \(path)!")
            return [:]
        }
        
        cachedEvents = collection
        
        for (id, eventList) in collection {
            for eventRawData in eventList {
                guard let mainData = eventRawData["main"] as? Data else {
                    print("WARNING: Key `main` not found in event collection cache!")
                    continue
                }
                
                guard let eventMain: Data = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
                    print("WARNING: Unable to decrypt event from collection cache!")
                    continue
                }
                
                if let json = try? JSON(data: eventMain) {
                    let event: Event = Event(eventInfo: json)
                    var orgSpecificEvents: Set<Event> = events[id] ?? []

                    // These two attributes need to be manually extracted from the JSON
                    event.hostID = json.dictionary?["Host ID"]?.string ?? event.hostID
                    event.hostTitle = json.dictionary?["Host title"]?.string ?? event.hostTitle
                    
                    event.eventVisual = eventRawData["cover"] as? UIImage
                    orgSpecificEvents.insert(event)
                    
                    events[id] = orgSpecificEvents
                } else {
                    print("WARNING: Unable to parse decrypted event main data as JSON!")
                }
            }
        }
        
        return events
    }
    
    static func writeToFile(orgID: String, events: Set<Event>, path: String) -> Bool {
        
        var collection = [[String : Any]]()
        
        for event in events {
            var eventRaw = [String : Any]()
            
            let mainEncrypted: Data? = NSData(data: try! event.encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)
            
            eventRaw["main"] = mainEncrypted
            eventRaw["cover"] = event.eventVisual
            
            collection.append(eventRaw)
        }
        
        Event.cachedEvents[orgID] = collection
                
        if NSKeyedArchiver.archiveRootObject(Event.cachedEvents, toFile: path) {
            return true
        } else {
            return false
        }
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
    
    
    /// Load the cover image for an event.
    func getCover(_ handler: ((Event) -> ())?) {
        if !hasVisual || eventVisual != nil { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventCover",
                           parameters: ["uuid": uuid])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.eventVisual = UIImage(data: data!)
            DispatchQueue.main.async {
                handler?(self)
            }
        }
        
        task.resume()
    }
    
    
    private var encodedJSON: JSON {
        var main = JSON()
        main.dictionaryObject?["uuid"] = uuid
        main.dictionaryObject?["Title"] = title
        main.dictionaryObject?["Location"] = location
        
        if startTime != nil {
            main.dictionaryObject?["Start time"] = DATE_FORMATTER.string(from: startTime!)
        }
        
        if endTime != nil {
            main.dictionaryObject?["End time"] = DATE_FORMATTER.string(from: endTime!)
        }
        
        main.dictionaryObject?["Description"] = eventDescription
        main.dictionaryObject?["Organization title"] = hostTitle
        main.dictionaryObject?["Organization"] = hostID
        main.dictionaryObject?["Published"] = published ? 1 : 0
        main.dictionaryObject?["Tags"] = tags.description
        main.dictionaryObject?["Has cover"] = hasVisual
        main.dictionaryObject?["Active"] = active ? 1 : 0
        
        return main
    }
    
    func copy() -> Event {
        let new = Event(eventInfo: encodedJSON)
        new.eventVisual = self.eventVisual
        return new
    }
    
    func renewUUID() {
        self.uuid = UUID().uuidString.lowercased()
    }
    
}


extension Event {
    enum Going: Int {
        case neutral = 0, interested, going
    }
}


extension Event: CustomStringConvertible, Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  uuid = \(uuid)\n"
        str += "  time = \(timeDescription)\n"
        str += "  location = \(location)\n"
        str += "  tags = \(tags.description)\n"
        str += "  published = \(published)"
        
        return str
    }
}
