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
    var role: String
    var department: String?
    var status: Status
    var joinedDate: Date?
    
    var profilePicture: UIImage?
    
    init(memberInfo: JSON) {
        let dictionary = memberInfo.dictionaryValue
        
        email = dictionary["Email"]?.string ?? ""
        name = dictionary["Alias"]?.string ?? ""
        role = dictionary["Role"]?.string ?? ""
        department = dictionary["Department"]?.string
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
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["Email"] = email
        json.dictionaryObject?["Alias"] = name
        json.dictionaryObject?["Date joined"] = DATE_FORMATTER.string(from: joinedDate ?? .distantPast)
        json.dictionaryObject?["Role"] = role
        json.dictionaryObject?["Org ID"] = orgID
        json.dictionaryObject?["Department"] = department
        json.dictionaryObject?["Status"] = status.rawValue
        
        return json
    }
    
    func getProfilePicture(_ handler: ((UIImage) -> ())?) {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetMemberPicture",
                           parameters: ["email": email])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else { return }
            
            if let image = UIImage(data: data!) {
                self.profilePicture = image
                DispatchQueue.main.async {
                    handler?(image)
                }
            }
        }
        
        task.resume()
    }
}


extension Membership: CustomStringConvertible {
    var description: String {
        return "Membership(email = \(email), club = \(orgID))"
    }
}
