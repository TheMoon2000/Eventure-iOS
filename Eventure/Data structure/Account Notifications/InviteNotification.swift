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
    override var shortString: String {
        return "[Member invitation: \(role)]"
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.role = rawContent.dictionary?["role"]?.string ?? ""
    }
}
