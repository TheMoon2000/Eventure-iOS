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
        didSet (oldValue) {
            if current != nil {
                UserDefaults.standard.set(ACCOUNT_TYPE_USER, forKey: KEY_ACCOUNT_TYPE)
                current?.save(needsUpload: false)
                Ticket.userTickets = Ticket.readFromFile()[current!.userID] ?? []
                Ticket.updateTickets()
                current?.saveEnabled = true
                User.viewedEvents.removeAll()
                print("Saving for user <\(current!.name)> is enabled at \(CURRENT_USER_PATH)")
            } else if oldValue != nil {
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
    
    static var viewedEvents = Set<String>()
    
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
    var favoritedEvents = Set<String>() { didSet { save() } }
    var interestedEvents = Set<String>() { didSet { save() } }
    
    /// Maps events to their calendar identifiers.
    var calendarIdentifiers: [String : String] { didSet { save() } }
    var subscriptions = Set<String>() { didSet { save() } }
    var tags = Set<Int>() { didSet { save() } }
    var memberships = Set<Membership>()
    let dateRegistered: String // Only for debugging purpose
    
    // MARK: - User Preferences
    var enabledNotifications = EnabledNotifications.all
    var interestPreference = CalendarPreference.alwaysAsk
    var favoritePreference = CalendarPreference.alwaysAsk
        
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
            let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [Int]) ?? [Int]()
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
            memberships.insert(Membership(memberInfo: memInfo))
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
        
        // Other info
        enabledNotifications = .init(rawValue: (dictionary["Enabled notifications"]?.int ?? 31))
        interestPreference = CalendarPreference(rawValue: (dictionary["Interest preference"]?.int ?? 1)) ?? .alwaysAsk
        favoritePreference = CalendarPreference(rawValue: (dictionary["Favorite preference"]?.int ?? 1)) ?? .alwaysAsk
        calendarIdentifiers = (dictionary["__calendar__"]?.dictionaryObject as? [String : String]) ?? [:]
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
            }
        }
    }
    
    func writeToFile(path: String) -> Bool {
        
        var json = JSON()
        
        // Account information
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
        
        // Preferences
        json.dictionaryObject?["Enabled notifications"] = enabledNotifications.rawValue
        json.dictionaryObject?["Interest preference"] = interestPreference.rawValue
        json.dictionaryObject?["Favorite preference"] = favoritePreference.rawValue
        json.dictionaryObject?["__calendar__"] = calendarIdentifiers
        
        // Profile information
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
                
                // Record information to retain from old `User` instance
                let currentImage = User.current?.profilePicture
                let calendarIdentifiers = User.current?.calendarIdentifiers
                let enabledNotifications = User.current?.enabledNotifications
                
                User.current = User(userInfo: json)
                
                // Copy over the retained information
                User.current?.profilePicture = currentImage
                User.current?.enabledNotifications = enabledNotifications ?? .all
                User.current?.calendarIdentifiers = calendarIdentifiers ?? [:]
                NotificationCenter.default.post(name: USER_SYNC_SUCCESS, object: nil)
            } else {
                print("WARNING: cannot parse '\(String(data: data!, encoding: .utf8)!)'; response: \(response!)")
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
            
            if interested {
                self.interestedEvents.insert(event.uuid)
                event.interested.insert(self.userID)
            } else {
                self.interestedEvents.remove(event.uuid)
                event.interested.remove(self.userID)
            }
        }
        
        task.resume()
        
        let style: UIAlertController.Style
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            style = .actionSheet
        } else {
            style = .alert
        }
        
        if interested {
            if interestPreference == .alwaysAdd {
                event.addToCalendar()
            } else if interestPreference == .alwaysAsk {
                let alert = UIAlertController(title: "Add event to calendar?", message: "Your current preference indicates that you should be asked every time you add an interested event. You can either make a decision just for this event, or set update the default settings for all interested events.", preferredStyle: style)
                alert.addAction(.init(title: "Add This Event", style: .default, handler: { _ in
                    event.addToCalendar()
                }))
                alert.addAction(.init(title: "Add All Future Events", style: .default, handler: { _ in
                    self.interestPreference = .alwaysAdd
                    event.addToCalendar()
                    self.pushSettings(.preferences) { _ in
                        NetworkStatus.removeTask()
                    }
                }))
                alert.addAction(.init(title: "Never Add", style: .default, handler: { _ in
                    self.interestPreference = .never
                    self.pushSettings(.preferences) { _ in
                        NetworkStatus.removeTask()
                    }
                }))
                alert.addAction(.init(title: "Don't Add This Event", style: .cancel))
                UIApplication.topMostViewController?.present(alert, animated: true)
            }
        } else if !favoritedEvents.contains(event.uuid) {
            event.removeFromCalendar()
        }
    }
    
    func syncFavorited(favorited: Bool, for event: Event, completion handler: ((Bool) -> ())? = nil) {
        
        let parameters = [
            "userId": String(uuid),
            "eventId": event.uuid,
            "favorited": favorited ? "1" : "0"
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
            
            if msg == INTERNAL_ERROR {
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
            
            if favorited {
                self.favoritedEvents.insert(event.uuid)
                event.favorited.insert(self.userID)
            } else {
                self.favoritedEvents.remove(event.uuid)
                event.favorited.remove(self.userID)
            }
        }
        
        task.resume()
        
        let style: UIAlertController.Style
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            style = .actionSheet
        } else {
            style = .alert
        }
        
        if favorited {
            if favoritePreference == .alwaysAdd {
                event.addToCalendar()
            } else if favoritePreference == .alwaysAsk {
                let alert = UIAlertController(title: "Add event to calendar?", message: "Your current preference indicates that you should be asked every time you add a favorite event. You can either make a decision just for this event, or set update the default settings for all favorite events.", preferredStyle: style)
                alert.addAction(.init(title: "Add This Event", style: .default, handler: { _ in
                    event.addToCalendar()
                }))
                alert.addAction(.init(title: "Add All Future Events", style: .default, handler: { _ in
                    self.favoritePreference = .alwaysAdd
                    event.addToCalendar()
                    self.pushSettings(.preferences) { _ in
                        NetworkStatus.removeTask()
                    }
                }))
                alert.addAction(.init(title: "Never Add", style: .default, handler: { _ in
                    self.favoritePreference = .never
                    self.pushSettings(.preferences) { _ in
                        NetworkStatus.removeTask()
                    }
                }))
                alert.addAction(.init(title: "Don't Add This Event", style: .cancel))
                UIApplication.topMostViewController?.present(alert, animated: true)
            }
        } else if !interestedEvents.contains(event.uuid) {
            event.removeFromCalendar()
        }
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
        
        NetworkStatus.addTask()

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
        
        if settings.contains(.preferences) {
            body.dictionaryObject?["Enabled notifications"] = enabledNotifications.rawValue
            body.dictionaryObject?["Interest preference"] = interestPreference.rawValue
            body.dictionaryObject?["Favorite preference"] = favoritePreference.rawValue
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
            
            NetworkStatus.removeTask()
            
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
    
    static func viewEvent(id: String) {
        
        if User.viewedEvents.contains(id) { return }
                
        var parameters = ["eventId": id]
        parameters["userId"] = User.current?.userID.description
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ViewEvent",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            let msg = String(data: data!, encoding: .utf8)
            if msg != "success" {
                print("WARNING: could not increment event view count!")
            } else {
                User.viewedEvents.insert(id)
            }
        }
        task.resume()
    }
    
    /// Prepare for a logout.
    static func logout() {
        
        UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
        User.current = nil
        AccountNotification.current.removeAll()
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/LogOut",
                           parameters: ["token": User.token ?? ""])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request)
        task.resume()
    }
}


extension User {
    
    enum Gender: Int {
        case unspecified = -1
        case male = 0
        case female = 1
        case non_binary = 2
        
        var description: String {
            return ["Unspecified", "Male", "Female", "Non-binary"][rawValue + 1]
        }
    }
    
    enum GraduationSeason: String {
        case spring = "Spring"
        case fall = "Fall"
    }
    
    struct EnabledNotifications: OptionSet {
        let rawValue: Int
        
        static let newEvents            = EnabledNotifications(rawValue: 1)
        static let eventUpdates         = EnabledNotifications(rawValue: 1 << 1)
        static let membershipInvites    = EnabledNotifications(rawValue: 1 << 2)
        static let newTickets           = EnabledNotifications(rawValue: 1 << 3)
        static let others               = EnabledNotifications(rawValue: 1 << 4)
        
        static let all                  = EnabledNotifications(rawValue: 1 << 5 - 1)
        static let none: EnabledNotifications = []
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
        static let preferences      = PushableSettings(rawValue: 1 << 13)
    }
    
    enum CalendarPreference: Int {
        case never = 0
        case alwaysAsk = 1
        case alwaysAdd = 2
        
        var description: String {
            return ["Never", "Always ask", "Always add"][rawValue]
        }
    }
    
    /// An object representing what year groups the user is interested in when browsing for organizations.
    struct YearGroup: OptionSet {
        let rawValue: Int
        
        static let undergraduate    = YearGroup(rawValue: 1)
        static let graduate         = YearGroup(rawValue: 2)
        static let both             = YearGroup(rawValue: 3)
        
        var stringValue: String {
            return [
                0: "Neither",
                1: "Undergraduate",
                2: "Graduate",
                3: "Both"
            ][rawValue] ?? "Error"
        }
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
