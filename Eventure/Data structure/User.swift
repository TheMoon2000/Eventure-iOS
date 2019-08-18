//
//  User.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: CustomStringConvertible {
    
    /// The current user, if the app is logged in.
    static var current: User?
    
    /// The UUID of the user.
    var uuid: Int
    var email: String
    var password_MD5: String
    var displayedName: String
    var gender: Gender
    var numberOfFavoriteEvents: Int = 0
    var subscriptions = [String]()
    var tags = [String]()
    var dateRegistered: String // Only for debugging purpose
    
    enum Gender: Int {
        case unspecified = -1
        case male = 0
        case female = 1
        case non_binary = 2
    }
    
    init(userInfo: JSON) {
        let dictionary = userInfo.dictionary!
        
        uuid = dictionary["uuid"]?.int ?? -1
        email = dictionary["Email"]?.string ?? ""
        password_MD5 = dictionary["Password MD5"]?.string ?? ""
        displayedName = dictionary["Displayed name"]?.string ?? ""
        gender = Gender(rawValue: (dictionary["Gender"]?.int ?? -1)) ?? .unspecified
        
        if let subscription_raw = dictionary["Subscriptions"]?.string {
            subscriptions = (JSON(parseJSON: subscription_raw).arrayObject as? [String]) ?? [String]()
        }
        
        if let tags_raw = dictionary["Tags"]?.string {
            tags = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
        }
        
        dateRegistered = dictionary["Date registered"]?.string ?? "Unknown"
    }
    
    var description: String {
        var str = "User <\(displayedName)>:\n"
        str += "  uuid = \(uuid)\n"
        str += "  email = \(email)\n"
        str += "  gender = \(gender.rawValue)\n"
        str += "  subscriptions = \(subscriptions)\n"
        str += "  tags = \(tags)\n"
        str += "  dateRegistered = \(dateRegistered)"
        
        return str
    }
}
