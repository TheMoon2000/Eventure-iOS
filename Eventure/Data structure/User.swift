//
//  User.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class User {
    
    /// The current user, if the app is logged in.
    static var current: User? {
        didSet {
            current?.save()
        }
    }
        
    /// The UUID of the user.
    let uuid: Int
    var email: String { didSet { save() } }
    var password_MD5: String { didSet { save() } }
    var displayedName: String { didSet { save() } }
    var gender: Gender { didSet { save() } }
    var profilePicture: UIImage? { didSet { save() } }
    
    /// A set of uuid strings for events which the user has favorited.
    var favoritedEvents = Set<String>() { didSet { save() } }
    var interestedEvents = Set<String>() { didSet { save() } }
    var subscriptions = Set<String>() { didSet { save() } }
    var tags = Set<String>() { didSet { save() } }
    let dateRegistered: String // Only for debugging purpose
    
    private var saveEnabled = false
    
    
    // MARK: - Profile information
    var fullName: String { didSet { save() } }
    var major: String { didSet { save() } }
    var interests: String { didSet { save() } }
    var resume: String { didSet { save() } }
    var linkedIn: String { didSet { save() } }
    var github: String { didSet { save() } }
    var yearOfGraduation: Int? { didSet { save() } }
    var seasonOfGraduation: GraduationSeason? { didSet { save() } }
    var comments: String { didSet { save() } }
    var graduation: String {
        if yearOfGraduation == nil || seasonOfGraduation == nil {
            return ""
        }
        return seasonOfGraduation!.rawValue + " \(yearOfGraduation!)"
    }
    
    var profileStatus: String {
        var allEmpty = true
        for item in [fullName, major, interests, resume, linkedIn, github, graduation, comments] {
            allEmpty = allEmpty && item.isEmpty
        }
        
        if allEmpty { return "Not Started" }
        
        var filledRequirements = true
        for item in [fullName, major, resume, graduation] {
            filledRequirements = filledRequirements && !item.isEmpty
        }
        
        if filledRequirements {
            return "Completed"
        } else {
            return "Incomplete"
        }
        
    }
    
    // MARK: - Initialization and instance methods
    
    required init(userInfo: JSON) {
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
        
        if let likedEvents_raw = dictionary["Liked events"]?.string {
            if let likedArray = (JSON(parseJSON: likedEvents_raw).arrayObject as? [String]) {
                favoritedEvents = Set(likedArray)
            }
        }
        
        if let interested_raw = dictionary["Interested"]?.string {
            if let interestArray = (JSON(parseJSON: interested_raw).arrayObject as? [String]) {
                interestedEvents = Set(interestArray)
            }
        }
        
        dateRegistered = dictionary["Date registered"]?.string ?? "Unknown"
        
        fullName = dictionary["Full name"]?.string ?? ""
        major = dictionary["Major"]?.string ?? ""
        yearOfGraduation = dictionary["Graduation year"]?.int
        if let tmp = dictionary["Graduation season"]?.string {
            seasonOfGraduation = User.GraduationSeason(rawValue: tmp)
        }
        resume = dictionary["Resume"]?.string ?? ""
        linkedIn = dictionary["LinkedIn"]?.string ?? ""
        github = dictionary["GitHub"]?.string ?? ""
        interests = dictionary["Interests"]?.string ?? ""
        comments = dictionary["Comments"]?.string ?? ""
        
        saveEnabled = true
    }
    
    // MARK: - Read & Write
    
    static func cachedUser(at path: String) -> User? {
        
        var user: User?
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            return nil
        }
        
        guard let cache = fileData as? [String : Data] else {
            print("WARNING: Cannot read cache as [String : Data]!")
            return nil
        }
            
        guard let userData = cache["main"] else {
            print("WARNING: Key `main` not found in cache file \(path)!")
            return nil
        }
        
        guard let decrypted = NSData(data: userData).aes256Decrypt(withKey: AES_KEY) else {
            print("WARNING: Unable to decrypt user data from \(path)!")
            return nil
        }
        
        if let json = try? JSON(data: decrypted) {
            user = User(userInfo: json)
            user?.profilePicture = UIImage(data: cache["profile"] ?? Data())
        } else {
            print("WARNING: Decrypted user data is not a valid JSON!")
        }
        
        return user
    }
    
    /// Short-cut for writeToFile().
    func save() {
        if !saveEnabled { return }
        
        if writeToFile(path: CURRENT_USER_PATH) == false {
            print("WARNING: cannot write user to \(CURRENT_USER_PATH)")
        } else {
            print("successfully wrote user data to \(CURRENT_USER_PATH)")
        }
    }
    
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
        json.dictionaryObject?["Liked events"] = self.favoritedEvents.description
        json.dictionaryObject?["Interested"] = self.interestedEvents.description
        
        json.dictionaryObject?["Full name"] = self.fullName
        json.dictionaryObject?["Major"] = self.major
        json.dictionaryObject?["Graduation year"] = self.yearOfGraduation
        json.dictionaryObject?["Graduation season"] = self.seasonOfGraduation?.rawValue
        json.dictionaryObject?["Resume"] = self.resume
        json.dictionaryObject?["GitHub"] = self.github
        json.dictionaryObject?["LinkedIn"] = self.linkedIn
        json.dictionaryObject?["Interests"] = self.interests
        json.dictionaryObject?["Comments"] = self.comments
        
        try? FileManager.default.createDirectory(at: ACCOUNT_DIR, withIntermediateDirectories: true, attributes: nil)
        
        
        let encrypted = NSData(data: try! json.rawData()).aes256Encrypt(withKey: AES_KEY)!
        
        // Handle profile picture
        
        var prepared: [String : Data] = ["main" : encrypted]
        prepared["profile"] = profilePicture?.pngData()
            
        return NSKeyedArchiver.archiveRootObject(
            prepared,
            toFile: path)
    }
}


extension User {
    
    enum Gender: Int {
        case unspecified = -1
        case male = 0
        case female = 1
        case non_binary = 2
    }
    
    enum GraduationSeason: String {
        case spring = "Spring"
        case fall = "Fall"
    }
    
}


extension User: CustomStringConvertible {
    
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
    
}
