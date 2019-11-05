//
//  EventStats.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventOverview {
    
    let eventID: String
    let eventTitle: String
    let interested: Int
    let favorites: Int
    let uniqueViews: Int
    var attendees = [Attendee]()
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        eventID = dictionary["uuid"]?.string ?? ""
        eventTitle = dictionary["Title"]?.string ?? ""
        
        if let intListRaw = dictionary["Interested"]?.string {
            interested = JSON(parseJSON: intListRaw).arrayValue.count
        } else {
            interested = 0
        }
        
        if let favListRaw = dictionary["Favorites"]?.string {
            favorites = JSON(parseJSON: favListRaw).arrayValue.count
        } else {
            favorites = 0
        }
        
        if let uniqueViewRaw = dictionary["Viewed by"]?.string {
            uniqueViews = JSON(parseJSON: uniqueViewRaw).arrayValue.count
        } else {
            uniqueViews = 0
        }
    }
    
}
