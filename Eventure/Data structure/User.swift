//
//  User.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: Profile {
    
    /// The current user, if the app is logged in.
    static var current: User? {
        didSet {
            if current != nil {
                UserDefaults.standard.set(ACCOUNT_TYPE_USER, forKey: KEY_ACCOUNT_TYPE)
                current?.save(needsUpload: false)
                Ticket.userTickets = Ticket.readFromFile()[current!.userID] ?? []
                Ticket.updateTickets()
                current?.saveEnabled = true
            } else {
                UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                Ticket.userTickets = []
            }
        }
    }
    
    static var token: String? {
        didSet {
            if User.current != nil {
                User.syncFromServer()
            } else if Organization.current != nil {
                Organization.syncFromServer()
            }
        }
    }
    
    var editable: Bool { return true }
        
    /// The UUID of the user.
    let uuid: Int
    var userID: Int { return uuid }
    var email: String { didSet { save() } }
    var password_MD5: String { didSet { save() } }
    var displayedName: String { didSet { save() } }
    var username: String {
        if !displayedName.isEmpty { return displayedName }
        if !fullName.isEmpty { return fullName }
        return email
    }
    
    var gender: Gender { didSet { save() } }
    var profilePicture: UIImage? { didSet { save() } }
    var numberOfAttendedEvents = 0 { didSet { save() } }
    
    /// A set of uuid strings for events which the user has favorited.
    var favoritedEvents = Set<String>() {
        didSet { save() } }
    var interestedEvents = Set<String>() { didSet { save() } }
    var subscriptions = Set<String>() { didSet { save() } }
    var tags = Set<String>() { didSet { save() } }
    var memberships = [Membership]()
    let dateRegistered: String // Only for debugging purpose
        
    /// Whether changes to the `User` instance would automatically be written to local cache.
    var saveEnabled = false
    
    /// Whether the app is in the middle of a sync session and is waiting for a response.
    static var waitingForSync = false
    
    /// Whether the changes made locally are yet to be uploaded.
    static var needsUpload = false
    
    // MARK: - Profile information
    var fullName: String { didSet { save() } }
    
    /// Alias of full name.
    var name: String { return fullName }
    
    /// Majors by IDs.
    var majors = Set<Int>() { didSet { save() } }
    
    var majorEncoded: String {
        return JSON(majors.map { $0 }).rawString([.castNilToNSNull: true])!
    }
    
    var interests: String { didSet { save() } }
    var resume: String { didSet { save() } }
    var linkedIn: String { didSet { save() } }
    var github: String { didSet { save() } }
    var graduationYear: Int? { didSet { save() } }
    var graduationSeason: GraduationSeason? { didSet { save() } }
    var comments: String { didSet { save() } }
    
    var profileStatus: String {
        var allEmpty = true
        for item in [fullName, interests, resume, linkedIn, github, graduation, comments] {
            allEmpty = allEmpty && item.isEmpty
        }
        
        allEmpty = allEmpty && majors.isEmpty
        
        if allEmpty { return "Not Started" }
        
        var filledRequirements = true
        for item in [fullName, resume, graduation] {
            filledRequirements = filledRequirements && !item.isEmpty
        }
        filledRequirements = filledRequirements && !majors.isEmpty
        
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
        
        for memInfo in (dictionary["Memberships"]?.arrayValue ?? []) {
            memberships.append(Membership(memberInfo: memInfo))
        }
                
        dateRegistered = dictionary["Date registered"]?.string ?? "Unknown"
        numberOfAttendedEvents = dictionary["# checked in"]?.int ?? 0
        
        fullName = dictionary["Full name"]?.string ?? ""
        if let majorString = dictionary["Major"]?.string {
            majors = Set((JSON(parseJSON: majorString).arrayObject as? [Int] ?? []))
        }
        
        graduationYear = dictionary["Graduation year"]?.int
        if let tmp = dictionary["Graduation season"]?.string {
            graduationSeason = User.GraduationSeason(rawValue: tmp)
        }
        
        resume = dictionary["Resume"]?.string ?? ""
        linkedIn = dictionary["LinkedIn"]?.string ?? ""
        github = dictionary["GitHub"]?.string ?? ""
        interests = dictionary["Interests"]?.string ?? ""
        comments = dictionary["Comments"]?.string ?? ""
    }
    
    // MARK: - Read & Write
    
    static func cachedUser(at path: String) -> User? {
        
        var user: User?
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            print("No user cache exists, assuming guest identity.")
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
            if user!.uuid == -1 { return nil }
            user?.profilePicture = UIImage(data: cache["profile"] ?? Data())
        } else {
            print("WARNING: Decrypted user data is not a valid JSON!")
        }
        
        return user
    }
    
    /// Short-cut for writeToFile().
    func save(needsUpload: Bool = true) {
        if needsUpload {
            User.needsUpload = true
        }

        if !saveEnabled || User.current != self { return }
        
        DispatchQueue.global(qos: .background).async {
            if self.writeToFile(path: CURRENT_USER_PATH) == false {
                print("WARNING: cannot write user to \(CURRENT_USER_PATH)")
            } else {
                print("successfully wrote user data to \(CURRENT_USER_PATH)")
            }
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
        json.dictionaryObject?["Major"] = majorEncoded
        json.dictionaryObject?["Graduation year"] = self.graduationYear
        json.dictionaryObject?["Graduation season"] = self.graduationSeason?.rawValue
        json.dictionaryObject?["Resume"] = self.resume
        json.dictionaryObject?["GitHub"] = self.github
        json.dictionaryObject?["LinkedIn"] = self.linkedIn
        json.dictionaryObject?["Interests"] = self.interests
        json.dictionaryObject?["Comments"] = self.comments
        json.dictionaryObject?["# checked in"] = self.numberOfAttendedEvents
        
        try? FileManager.default.createDirectory(at: ACCOUNT_DIR, withIntermediateDirectories: true, attributes: nil)
        
        
        let encrypted = NSData(data: try! json.rawData()).aes256Encrypt(withKey: AES_KEY)!
        
        // Handle profile picture
        
        var prepared: [String : Data] = ["main" : encrypted]
        prepared["profile"] = profilePicture?.pngData()
            
        return NSKeyedArchiver.archiveRootObject(
            prepared,
            toFile: path)
    }
    
    /// Sync the local user data with the server's.
    static func syncFromServer() {
        if User.current == nil { return }
        
        var parameters = ["uuid": String(User.current!.uuid)]
        parameters["token"] = User.token
        parameters["build"] = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        
            
        User.waitingForSync = true
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetUserInfo",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            User.waitingForSync = false
            
            guard error == nil else {
                print(error!)
                NotificationCenter.default.post(name: USER_SYNC_FAILED, object: nil)
                return
            }
            
            if let json = try? JSON(data: data!) {
                let currentImage = User.current?.profilePicture
                User.current = User(userInfo: json)
                User.current?.profilePicture = currentImage
                NotificationCenter.default.post(name: USER_SYNC_SUCCESS, object: nil)
            } else {
                print("WARNING: cannot parse '\(String(data: data!, encoding: .utf8)!)'")
                NotificationCenter.default.post(name: USER_SYNC_FAILED, object: nil)
            }
        }
        
        task.resume()
    }
    
    func syncInterested(interested: Bool, for event: Event, completion handler: ((Bool) -> ())? = nil) {
        let parameters = [
            "userId": String(uuid),
            "eventId": event.uuid,
            "interested": interested ? "1" : "0"
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/MarkEvent",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8) ?? INTERNAL_ERROR
            
            DispatchQueue.main.async {
                handler?(msg != INTERNAL_ERROR)
            }
        }
        
        task.resume()
    }
    
    
    /// Load the profile picture for the current user.
    func getProfilePicture(_ handler: ((User) -> ())?) {
        if profilePicture != nil { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetProfilePicture",
                           parameters: ["userId": String(uuid)])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                handler?(self)
                return // Don't display any alert here
            }
            
            self.profilePicture = UIImage(data: data!)
            if self.profilePicture != nil {
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
    }
    
    func uploadProfilePicture(new: UIImage, _ handler: ((Bool) -> ())?) {
        
        let original = profilePicture
        profilePicture = new.sizeDown()
        
        let url = URL(string: API_BASE_URL + "account/UpdateProfilePicture")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = ["userId": String(uuid)]
        
        var fileData = [String : Data]()
        fileData["picture"] = new.sizeDownData()
        
        request.addMultipartBody(parameters: parameters as [String : String],
                                 files: fileData)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                self.profilePicture = original
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }

            let msg = String(data: data!, encoding: .utf8)!
            switch msg {
            case INTERNAL_ERROR:
                self.profilePicture = original
                handler?(false)
            case "success":
                print("User profile updated")
                DispatchQueue.main.async {
                    handler?(true)
                }
            default:
                self.profilePicture = original
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    /**
    Call this method when some of the user's settings information needs to be uploaded to the server.
    
    - Parameters:
       - settings: The subset of user settings that should be updated.
       - handler: Optional handler that will be called after this method attempts to upload the user settings.
    */
    func pushSettings(_ settings: PushableSettings, _ handler: ((Bool) -> ())?) {
        
        var body = JSON()
        
        if settings.contains(.displayedName) {
            body.dictionaryObject?["Displayed name"] = displayedName
        }
        
        if settings.contains(.gender) {
            body.dictionaryObject?["Gender"] = gender.rawValue
        }
        
        if settings.contains(.email) {
            body.dictionaryObject?["Email"] = email
        }
        
        if settings.contains(.tags) {
            body.dictionaryObject?["Tags"] = tags.description
        }
        
        if settings.contains(.fullName) {
            body.dictionaryObject?["Full name"] = fullName
        }
        
        if settings.contains(.graduationYear) {
            body.dictionaryObject?["Graduation year"] = graduationYear
        }
        
        if settings.contains(.graduationSeason) {
            body.dictionaryObject?["Graduation season"] = graduationSeason?.rawValue
        }
        
        if settings.contains(.major) {
            body.dictionaryObject?["Major"] = majorEncoded
        }
        
        if settings.contains(.resumeLink) {
            body.dictionaryObject?["Resume"] = resume
        }
        
        if settings.contains(.linkedIn) {
            body.dictionaryObject?["LinkedIn"] = linkedIn
        }
        
        if settings.contains(.github) {
            body.dictionaryObject?["GitHub"] = github
        }
        
        if settings.contains(.interests) {
            body.dictionaryObject?["Interests"] = interests
        }
        
        if settings.contains(.profileComments) {
            body.dictionaryObject?["Comments"] = comments
        }
        
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/UpdateUserInfo",
                           parameters: ["uuid": String(uuid)])!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addAuthHeader()
        request.httpBody = try? body.rawData()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)!
            
            DispatchQueue.main.async {
                handler?(msg == "success")
            }
        }
        
        task.resume()
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
    
    struct EnabledNotifications: OptionSet {
        let rawValue: Int
        
        static let newEvents                = EnabledNotifications(rawValue: 1)
        static let eventUpdates             = EnabledNotifications(rawValue: 1 << 1)
        static let membershipInvites        = EnabledNotifications(rawValue: 1 << 2)
        static let ticketTransferRequests   = EnabledNotifications(rawValue: 1 << 3)
    }
    
    struct PushableSettings: OptionSet {
        let rawValue: Int
        
        static let displayedName    = PushableSettings(rawValue: 1)
        static let email            = PushableSettings(rawValue: 1 << 1)
        static let gender           = PushableSettings(rawValue: 1 << 2)
        static let tags             = PushableSettings(rawValue: 1 << 3)
        static let fullName         = PushableSettings(rawValue: 1 << 4)
        static let graduationYear   = PushableSettings(rawValue: 1 << 5)
        static let graduationSeason = PushableSettings(rawValue: 1 << 6)
        static let major            = PushableSettings(rawValue: 1 << 7)
        static let resumeLink       = PushableSettings(rawValue: 1 << 8)
        static let linkedIn         = PushableSettings(rawValue: 1 << 9)
        static let github           = PushableSettings(rawValue: 1 << 10)
        static let interests        = PushableSettings(rawValue: 1 << 11)
        static let profileComments  = PushableSettings(rawValue: 1 << 12)
    }
    
}


extension User: CustomStringConvertible, Hashable {
    
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
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }
    
}
