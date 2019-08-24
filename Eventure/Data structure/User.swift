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
    var favoritedEvents = Set<String>()
    var goingList = [String: Int]()
    var subscriptions = Set<String>()
    var tags = Set<String>()
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
            let subsArray = (JSON(parseJSON: subscription_raw).arrayObject as? [String]) ?? [String]()
            subscriptions = Set(subsArray)
        }
        
        if let tags_raw = dictionary["Tags"]?.string {
            let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
            tags = Set(tagsArray)
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
        str += "  # of favorite events = \(favoritedEvents.count)"
        str += "  dateRegistered = \(dateRegistered)"
        
        return str
    }
    
    // MARK: - Read & Write
    
    func writeToFile(path: String) -> Bool {
        var json = JSON()
        json.dictionaryObject?["uuid"] = self.uuid
        json.dictionaryObject?["Email"] = self.email
        json.dictionaryObject?["Password MD5"] = self.password_MD5
        json.dictionaryObject?["Displayed name"] = self.displayedName
        json.dictionaryObject?["Gender"] = self.gender.rawValue
        json.dictionaryObject?["Subscriptions"] = self.subscriptions.description
        json.dictionaryObject?["Tags"] = self.tags.description
        json.dictionaryObject?["Date registered"] = self.dateRegistered
        
        let encrypted = NSData(data: try! json.rawData()).aes256Encrypt(withKey: AES_KEY)
        return NSKeyedArchiver.archiveRootObject(
            encrypted!,
            toFile: ACCOUNT_DIR.path + "/" + "user"
        )
    }
}

