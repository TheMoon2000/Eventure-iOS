//
//  NewEventNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewEventNotification: AccountNotification {
    var eventID = ""
    var eventTitle = ""
    override var shortString: String {
        return "New event: \(eventTitle)"
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.eventTitle = rawContent.dictionary?["eventTitle"]?.string ?? ""
        self.eventID = rawContent.dictionary?["eventId"]?.string ?? ""
    }
}
