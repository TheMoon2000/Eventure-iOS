//
//  StatsManager.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class StatsManager {
    
    /// A dictionary containing the event IDs mapped to the event overviews.
    var events = [String: EventOverview]()
    var attendees = [Attendee]()
    
    init(source: JSON) throws {
        
        guard let eventsJSON = source.dictionary?["events"]?.array,
            let attendeesJSON = source.dictionary?["attendees"]?.array else {
            throw Errors.invalidInput
        }
        
        for eventData in eventsJSON {
            let event = EventOverview(json: eventData)
            events[event.eventID] = event
        }
        
        for a in attendeesJSON {
            let attendee = Attendee(json: a)
            events[attendee.eventID]?.attendees.append(attendee)
            attendees.append(attendee)
        }
    }
    
    /// Returns a tuple array containing names of the top 10 majors (of which "Unknown" is always the last item) and the number of attendees. If there are less than 10 majors, return all the majors.
    var top10Majors: [(major: String, count: Int)] {
        var tally = [Major: Int]() // Maps from major to count.
        
        for attendee in attendees {
            attendee.majors.forEach { tally[$0] = (tally[$0] ?? 0) + 1 }
        }
        
        // Sort the majors in decending order by their popularity.
        var majors = tally.sorted { $0.value > $1.value } . map { ($0.key.fullName, $0.value) }
        
        // Limit the output to 10 majors only.
        if majors.count > 10 {
            majors = Array(majors[0..<10])
        }
        
        return majors
    }
    
    /// The number of undeclared attendees within the provided data.
    var undeclaredCount: Int {
        return attendees.filter { $0.majors.isEmpty } . count
    }
    
    
    /// Returns a tuple array containing data about the top 10 most popular events hosted by the current organization **in decending order by the number of “interested” users**. If there are less than 10 events in total, return the data for all the events.
    var top10Events: [(title: String, views: Int, interested: Int, attended: Int)] {
        // TODO
        
        var allEvents = [(title: String, views: Int, interested: Int, attended: Int)]()
        
        events.forEach { eventID, info in
            allEvents.append((info.eventTitle, info.views, info.interested, info.attendees.count))
        }
        
        allEvents.sort { event1, event2 in
            
            let max1 = max(event1.views, event1.interested, event1.attended)
            let max2 = max(event2.views, event2.interested, event2.attended)
            
            return max1 < max2
        }
                
        if allEvents.count > 10 {
            allEvents = Array(allEvents[0..<10])
        }
        
        return allEvents
        
        /*
        return [
            ("Some other new event", 15, 3, 0),
            ("Not very popular event", 46, 36, 12),
            ("Random event", 132, 79, 85),
            ("Third most popular event", 190, 141, 99),
            ("Info session", 265, 176, 90),
            ("Most popular event", 300, 210, 180),
        ]*/
    }
    
    /// Returns an integer array containing the raw data for histogram on the number of events that attendees have attended for this organization.
    var attendeeParticipation: [Int] {
        // TODO
        return []
    }
    
    /// Returns the average number of events that attendees have attended for this organization.
    var averageParticipation: Double {
        return 0.0
    }
    
}

extension StatsManager {
    enum Errors: Error {
        case invalidInput
    }
}
