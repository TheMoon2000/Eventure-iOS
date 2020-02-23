//
//  TicketNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON
import BonMot

/// A subclass of user account notifications that handles all notifications that involve a ticket.
class TicketNotification: AccountNotification {
    var eventTitle = ""
    
    override var contentType: AccountNotification.ContentType {
        return .newTicket
    }
    
    override var shortString: NSAttributedString {
        return "[Ticket: \(eventTitle)]".styled(with: .basicStyle)
    }
    
    var displayString: NSAttributedString {
        
        let textStyle = StringStyle(
            .font(UIFont.appFontRegular(15)),
            .lineHeightMultiple(1.1),
            .color(AppColors.invertedLabel)
        )
        
        let linkStyle = textStyle.byAdding(
            .link(URL(string: "localhost")!),
            .color(AppColors.link)
        )
        
        return NSAttributedString.composed(of: [
            "You have received a new ticket for the event “\(eventTitle)”. Please view it at your ".styled(with: textStyle),
            "Ticket Center".styled(with: linkStyle),
            ".".styled(with: textStyle)
            ])
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.eventTitle = rawContent.dictionary?["eventTitle"]?.string ?? ""
    }
}
