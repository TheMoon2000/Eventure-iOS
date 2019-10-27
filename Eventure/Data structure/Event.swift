//
//  Event.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import EventKit

class Event {
    static var current: Event?
    static var drafts = [Event]()    
    private static var cachedEvents = [String: [[String: Any]]]()
    
    var uuid: String
    var title: String
    var location: String
    var checkinTime: Int // How many seconds before event starts
    var startTime: Date?
    var endTime: Date?
    var eventDescription: String
    var eventVisual: UIImage?
    var hasVisual = false
    var hostID: String
    var hostTitle: String
    var interested = Set<Int>()
    var favorited = Set<Int>()
    var tags = Set<String>()
    var membersOnly = false
    var capacity = 0
    var secureCheckin = false
    var requiresTicket = false
    var ticketStyle: QRStyle = .standard
    var lastModified: Date?
    
    var hasBannerImage = false
    var bannerImage: UIImage?
    
    /// An array containing all the ticket types for the event.
    var admissionTypes = Set<AdmissionType>()
    var admissionTypesEncoded: String {
        var json = JSON()
        for type in admissionTypes {
            json[type.id] = type.encodedJSON
        }
        return json.rawString([.castNilToNSNull : true])!
    }
    
    // Only used as a temporary storage
    var hostInfo: Organization?
    
    var published: Bool
    var active: Bool
    
    // MARK: Computed properties
    
    /// A description of the start time of the event.
    var timeDescription: String {
        return startTime?.readableString() ?? "Unspecified"
    }
    
    /// A description of the duration of the event.
    var duration: String {
        let dc = DateComponentsFormatter()
        dc.allowedUnits = [.month, .weekOfMonth, .day, .hour, .minute]
        dc.zeroFormattingBehavior = [.dropLeading, .dropTrailing]
        dc.maximumUnitCount = 2
        dc.unitsStyle = .full
        
        if startTime != nil && endTime != nil {
            if endTime == startTime {
                return "Unspecified"
            }
            return dc.string(from: endTime!.timeIntervalSince(startTime!))!
        } else {
            return "Unspecified"
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
        self.checkinTime = 3600
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
        if location.isEmpty { location = "TBA" }
        
        checkinTime = dictionary["Check-in time"]?.int ?? 3600
        
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
        
        if let admissionTypes_raw = dictionary["Ticket types"]?.string {
            var tmp = Set<AdmissionType>()
            for (k, v) in JSON(parseJSON: admissionTypes_raw).dictionaryValue {
                tmp.insert(AdmissionType(json: v, admissionID: k, eventID: uuid))
            }
            admissionTypes = tmp
        }
        
        active = (dictionary["Active"]?.int ?? 1) == 1
        hasVisual = (dictionary["Has cover"]?.int ?? 0) == 1
        hasBannerImage = (dictionary["Has banner"]?.int ?? 0) == 1
        capacity = dictionary["Capacity"]?.int ?? 0
        secureCheckin = (dictionary["Strict"]?.int ?? 0) == 1
        requiresTicket = (dictionary["Requires ticket"]?.int ?? 0) == 1
        
        if let int_raw = dictionary["Interested"]?.string {
            if let intArray = JSON(parseJSON: int_raw).arrayObject as? [Int] {
                interested = Set(intArray)
            }
        }
        
        if let fav_raw = dictionary["Favorites"]?.string {
            if let favArray = JSON(parseJSON: fav_raw).arrayObject as? [Int] {
                favorited = Set(favArray)
            }
        }
       
        if let dateString = dictionary["Last modified"]?.string {
            lastModified = DATE_FORMATTER.date(from: dateString)
        }
        
        if let ticketStyleRaw = dictionary["Ticket QR style"]?.int {
            if let style = QRStyle(rawValue: ticketStyleRaw) {
                self.ticketStyle = style
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

                    event.eventVisual = eventRawData["cover"] as? UIImage
                    event.bannerImage = eventRawData["banner"] as? UIImage
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
            eventRaw["banner"] = event.bannerImage
            
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
    func getBanner(_ handler: ((Event) -> ())?) {
        if !hasBannerImage { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventBanner",
                           parameters: ["eventId": uuid])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.bannerImage = UIImage(data: data!)
            if self.bannerImage != nil {
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
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
            if self.eventVisual != nil {
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
    }
    
    /// Adds useful information such as quantity and revenue to the event's ticket information.
    func updateAdmissionTypes(handler: ((Bool) -> ())?) {
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetTicketInfo",
                           parameters: ["eventId": uuid])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
                        
            if let json = try? JSON(data: data!).dictionaryValue {
                var newTypes = Set<AdmissionType>()
                
                for (key, value) in json {
                    newTypes.insert(AdmissionType(json: value, admissionID: key, eventID: self.uuid))
                }
                self.admissionTypes = newTypes
                DispatchQueue.main.async {
                    handler?(true)
                }
            } else {
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    
    private var encodedJSON: JSON {
        var main = JSON()
        main.dictionaryObject?["uuid"] = uuid
        main.dictionaryObject?["Title"] = title
        main.dictionaryObject?["Location"] = location
        
        main.dictionaryObject?["Check-in time"] = checkinTime
        
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
        main.dictionaryObject?["Has banner"] = hasBannerImage
        main.dictionaryObject?["Active"] = active ? 1 : 0
        main.dictionaryObject?["Capacity"] = capacity
        main.dictionaryObject?["Strict"] = secureCheckin
        main.dictionaryObject?["Requires ticket"] = requiresTicket ? 1 : 0
        main.dictionaryObject?["Ticket types"] = admissionTypesEncoded
        main.dictionaryObject?["Ticket QR style"] = ticketStyle.rawValue
        
        return main
    }
    
    static let lastestFirst: ((Event, Event) -> Bool) = { e1, e2 in
        if e1.startTime == nil {
            return false
        } else if e2.startTime == nil {
            return true
        } else {
            return e1.startTime! >= e2.startTime!
        }
    }
    
    static let oldestFirst: ((Event, Event) -> Bool) = { e1, e2 in
        if e1.startTime == nil {
            return false
        } else if e2.startTime == nil {
            return true
        } else {
            return e1.startTime! <= e2.startTime!
        }
    }
    
    func copy() -> Event {
        let new = Event(eventInfo: encodedJSON)
        new.eventVisual = self.eventVisual
        return new
    }
    
    func renewUUID() {
        self.uuid = UUID().uuidString.lowercased()
    }
    
    func fetchHostInfo(_ handler: ((Organization) -> ())?) {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: ["orgId": hostID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return
            }
            
            if let json = try? JSON(data: data!) {
                self.hostInfo = Organization(orgInfo: json)
                DispatchQueue.main.async {
                    handler?(self.hostInfo!)
                }
            }
        }
        
        task.resume()
    }
    
    func addToCalendar() {
        let store = EKEventStore()
        if let id = User.current?.calendarIdentifiers[uuid], store.event(withIdentifier: id) != nil {
            print("Event with id \(id) already added!")
            return
        }
        store.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                let newEvent = EKEvent(eventStore: store)
                newEvent.title = self.title
                newEvent.startDate = self.startTime ?? Date()
                newEvent.endDate = self.endTime ?? newEvent.startDate.addingTimeInterval(7200)
                newEvent.location = self.location
                newEvent.calendar = store.defaultCalendarForNewEvents
                newEvent.addAlarm(.init(relativeOffset: -3600))
                newEvent.addAlarm(.init(relativeOffset: -900))
                newEvent.notes = "This event is hosted by \(self.hostTitle)."
                do {
                    try store.save(newEvent, span: .thisEvent)
                    User.current?.calendarIdentifiers[self.uuid] = newEvent.eventIdentifier
                } catch let error {
                    print("Failed to save event: \(error)")
                }
            }
        }
    }
    
    func removeFromCalendar() {
        let store = EKEventStore()
        if let id = User.current?.calendarIdentifiers[uuid], let calendarEvent = store.event(withIdentifier: id) {
            try? store.remove(calendarEvent, span: .thisEvent)
        }
    }
}


extension Event {
    enum Going: Int {
        case neutral = 0, interested, going
    }
    
    enum QRStyle: Int {
        case standard = 0, imageBelow
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
