//
//  InviteNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A subclass of user account notifications that presents a club membership invitation.
class InviteNotification: AccountNotification {
    var role = ""
    var status = Status.pending
    
    override var type: AccountNotification.ContentType {
        return .membershipInvite
    }
    
    override var shortString: NSAttributedString {
        return "[Member invitation: \(role)]".styled(with: .basicStyle)
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.role = rawContent.dictionary?["role"]?.string?.decoded ?? ""
        self.status = Status(rawValue: rawContent.dictionary?["status"]?.int ?? 0) ?? .pending
    }
    
    enum Status: Int {
        case accepted = 1
        case pending = 0
        case declined = -1
    }
}
