//
//  EventNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventNotification: AccountNotification {
    var message = ""
    var eventID = ""
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.message = rawContent.dictionary?["message"]?.string ?? ""
        self.eventID = rawContent.dictionary?["eventId"]?.string ?? ""
    }
}
