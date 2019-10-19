//
//  Membership.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Records a membership relation.
class Membership: Hashable {
    
    let userID: Int?
    var email: String
    var name: String
    let orgID: String
    var majors = Set<Int>()
    var joinedDate: Date?
    
    init(memberInfo: JSON) {
        let dictionary = memberInfo.dictionaryValue
        
        userID = dictionary["User ID"]?.int
        email = dictionary["Email"]?.string ?? ""
        name = dictionary["Full name"]?.string ?? ""
        if name.isEmpty {
            name = dictionary["Displayed name"]?.string ?? ""
        }
        orgID = dictionary["Organization ID"]?.string ?? "Unknown Organization"
        
        if let majorString = dictionary["Major"]?.string {
            majors = Set((JSON(parseJSON: majorString).arrayObject as? [Int] ?? []))
        }

        if let dateRaw = dictionary["Date joined"]?.string {
            joinedDate = DATE_FORMATTER.date(from: dateRaw)
        }
    }
    
    static func ==(lhs: Membership, rhs: Membership) -> Bool {
        if lhs.orgID != rhs.orgID { return false }
        if lhs.userID != -1 && rhs.userID != -1 { return lhs.userID == rhs.userID }
        return lhs.email.lowercased() == rhs.email.lowercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
        hasher.combine(orgID)
        hasher.combine(email.lowercased())
    }
}
