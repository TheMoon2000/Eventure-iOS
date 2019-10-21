//
//  TicketNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A subclass of user account notifications that handles all notifications that involve a ticket.
class TicketNotification: AccountNotification {
    var message = ""
    var ticketID = ""
    override var shortString: String {
        return message
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.message = rawContent.dictionary?["message"]?.string ?? ""
        self.ticketID = rawContent.dictionary?["ticketId"]?.string ?? ""
    }
}
