//
//  Membership.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Records a membership relation. Memberships should *NOT* be cached.
class Membership: Hashable {
    
    var email: String
    var name: String
    let orgID: String
    var department: String?
    var status: Status
    var joinedDate: Date?
    
    init(memberInfo: JSON) {
        let dictionary = memberInfo.dictionaryValue
        
        email = dictionary["Email"]?.string ?? ""
        name = dictionary["Alias"]?.string ?? ""
        orgID = dictionary["Org ID"]?.string ?? "Unknown Organization"

        if let dateRaw = dictionary["Date joined"]?.string {
            joinedDate = DATE_FORMATTER.date(from: dateRaw)
        }
        
        status = Status(rawValue: (dictionary["Status"]?.int ?? 0))!
    }
    
    static func ==(lhs: Membership, rhs: Membership) -> Bool {
        return lhs.email.lowercased() == rhs.email.lowercased() && lhs.orgID == rhs.orgID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(orgID)
        hasher.combine(email.lowercased())
    }
    
    enum Status: Int {
        case declined = -1
        case active = 1
        case pending = 0
    }
}


extension Membership: CustomStringConvertible {
    var description: String {
        return "Membership(email = \(email), club = \(orgID))"
    }
}
