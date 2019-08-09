//
//  Organization.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Organization: CustomStringConvertible {
    static var current: Organization?
    
    var id: String
    var title: String
    var orgDescription: String
    var website: String
    var members = [String]()
    var password_MD5: String
    var tags = [String]()
    var contactName: String
    var contactEmail: String
    var active: Bool
    var dateRegistered: String
    
    
    init(title: String) {
        id = ""
        self.title = title
        orgDescription = ""
        website = ""
        members = []
        password_MD5 = ""
        tags = []
        contactName = ""
        contactEmail = ""
        active = true
        dateRegistered = ""
    }
    
    static var empty: Organization {
        return Organization(title: "")
    }
    
    init(orgInfo: JSON) {
        let dictionary = orgInfo.dictionary!
        
        id = dictionary["ID"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        orgDescription = dictionary["Description"]?.string ?? ""
        website = dictionary["Website"]?.string ?? ""
        
        if let members_raw = dictionary["Members"]?.string {
            members = (JSON(parseJSON: members_raw).arrayObject as? [String]) ?? [String]()
        }
        
        if let tags_raw = dictionary["Tags"]?.string {
            tags = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
        } else {
            tags = [String]()
        }
        
        password_MD5 = dictionary["Password MD5"]?.string ?? ""
        contactName = dictionary["Name"]?.string ?? ""
        contactEmail = dictionary["Email"]?.string ?? ""
        active = (dictionary["Active"]?.int ?? 1) == 1
        dateRegistered = dictionary["Date registered"]?.string ?? ""
    }
    
    var description: String {
        var str = "Organization \"\(String(describing: title))\":\n"
        str += "  id = \(String(describing: id))\n"
        str += "  website = \(String(describing: website))\n"
        str += "  tags = \(tags.description)\n"
        str += "  date registered = \(String(describing: dateRegistered))"
        
        return str
    }
    
}
