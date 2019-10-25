//
//  AccountNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import BonMot

class AccountNotification: CustomStringConvertible {
    
    static var cachedNotifications = [Int: [[String: Any]]]()
    static var cachedLogos = [String: UIImage]()
    
    /// Stores all the notifications for the current user. A set structure is used to prevent duplicates. The arrays are sorted by date in ascending order.
    static var current = [Sender: [AccountNotification]]()
    static var currentUpdateTime = Date.distantPast
    static var SYSTEM_ID = "__SYSTEM__"
    static var unreadCount: Int {
        let unreadBySender = current.map { _, notifications in
            return notifications.filter { !$0.read }.count
        }
        return unreadBySender.reduce(0, { sum, next in
            return sum + next
        })
    }
    
    let userID: Int
    
    /// Accurate within milliseconds of time. This is also the unique identifier for a notification.
    var creationDate: Date
    
    var rawContent: JSON
    let sender: Sender
    var read = true
    
    private var contentType: ContentType?
    
    var type: ContentType {
        return contentType ?? .unsupported
    }
    
    private var message: String
    
    var shortString: NSAttributedString {
        return message.styled(with: .basicStyle)
    }
    
    var senderLogo: UIImage? {
        
        if sender.senderID == AccountNotification.SYSTEM_ID {
            return #imageLiteral(resourceName: "user_default")
        } else {
            return AccountNotification.cachedLogos[sender.senderID]
        }
    }
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        self.userID = dictionary["User ID"]?.int ?? -1
        self.creationDate = PRECISE_FORMATTER.date(from: dictionary["Date"]!.stringValue) ?? .distantPast
        self.message = dictionary["Content"]?.string ?? "No content."
        
        if let json = dictionary["Content"], !json.isEmpty {
            rawContent = json
        } else {
            self.rawContent = JSON(parseJSON: dictionary["Content"]!.stringValue)
        }
        
        self.contentType = ContentType(rawValue: dictionary["Type"]?.string ?? "")
        
        let senderID = dictionary["Sender"]?.string ?? AccountNotification.SYSTEM_ID
        let senderName = dictionary["Sender title"]?.string ?? "Unknown"
        self.sender = Sender(name: senderName, id: senderID)
        
        self.read = (dictionary["Read"]?.int ?? 0) == 1
        getLogoImage(nil)
    }
    
    static func new(json: JSON) -> AccountNotification? {
        let dictionary = json.dictionaryValue
        guard let typeString = dictionary["Type"]?.string else { return nil }
        guard dictionary["Date"]?.string != nil else { return nil }
        
        let type = ContentType(rawValue: typeString)
        switch type {
        case .newEvent:
            return NewEventNotification(json: json)
        case .membershipInvite:
            return InviteNotification(json: json)
        case .eventUpdate:
            return EventUpdateNotification(json: json)
        default:
            return AccountNotification(json: json)
        }
    }
    
    /// Load the logo image for the sender organization.
    func getLogoImage(_ handler: ((UIImage) -> ())?) {
        
        if sender.senderID == AccountNotification.SYSTEM_ID {
            handler?(#imageLiteral(resourceName: "user_default"))
            return
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": sender.senderID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in

            guard error == nil else {
                print("WARNING: Get logo image returned error for organization!")
                return // Don't display any alert here
            }
            
            if let newLogo = UIImage(data: data!) {
                AccountNotification.cachedLogos[self.sender.senderID] = newLogo
                DispatchQueue.main.async {
                    handler?(newLogo)
                }
            }
        }

        task.resume()
    }
    
    static func syncFromServer(_ handler: ((Bool) -> ())?) {
        
        guard let userID = User.current?.userID else { return }
        
        let parameters = [
            "userId": String(userID),
            "lowerBound": DATE_FORMATTER.string(from: currentUpdateTime)
        ]
        
        let url = URL.with(base: PHP7_API_BASE_URL,
                           API_Name: "account/GetUserNotifications",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            if let json = try? JSON(data: data!), let nArray = json.array {
                var tmp = current // [Sender: [AccountNotification]]()
                var newUpdateTime: Date?
                for rawNotification in nArray {
                    
                    if newUpdateTime == nil, let rawDate = rawNotification.dictionary?["Last updated"]?.string {
                        newUpdateTime = PRECISE_FORMATTER.date(from: rawDate)
                    }
                    
                    if let new = new(json: rawNotification) {
                        if tmp[new.sender] == nil {
                            tmp[new.sender] = [new]
                        } else {
                            tmp[new.sender]?.append(new)
                        }
                    }
                }
                
                tmp.keys.forEach { key in
                    tmp[key]!.sort { $0.creationDate <= $1.creationDate }
                }
                
                current = tmp
                if let updateTime = newUpdateTime {
                    currentUpdateTime = updateTime
                }
                AccountNotification.save()
                DispatchQueue.main.async {
                    handler?(true)
                }
            } else {
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["User ID"] = userID
        json.dictionaryObject?["Type"] = type.rawValue
        json.dictionaryObject?["Date"] = PRECISE_FORMATTER.string(from: creationDate)
        if type == .plain {
            json.dictionaryObject?["Content"] = message
        } else {
            json.dictionaryObject?["Content"] = rawContent
        }
        json.dictionaryObject?["Sender"] = sender.senderID
        json.dictionaryObject?["Sender title"] = sender.name
        json.dictionaryObject?["Read"] = read ? 1 : 0
        
        return json
    }
    
    static func readLogos() {
        if let logoData = NSKeyedUnarchiver.unarchiveObject(withFile: LOGO_CACHE) as? [String : UIImage] {
            cachedLogos = logoData
        }
    }
    
    static func readFromFile(userID: Int) {
        AccountNotification.currentUpdateTime = .distantPast
        readLogos()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: NOTIFICATIONS_PATH) else {
            return
        }
        
        guard let collection = fileData as? [Int: [[String: Any]]] else {
            print("WARNING: Cannot read notification collection at \(NOTIFICATIONS_PATH)!")
            return
        }
                
        cachedNotifications = collection
        print("Message cache recovered:", cachedNotifications.mapValues { $0.count })
        
        guard let userCollection = collection[userID] else {
            print("WARNING: No notification cache was found for user <id=\(userID)>!");
            
            return
        }
        
        var dateUpdated = false
        
        for notificationRaw in userCollection {
            guard let mainData = notificationRaw["main"] as? Data else {
                print("WARNING: Key `main` not found in notification collection cache!")
                continue
            }
            
            guard let notificationMain: Data = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
                print("WARNING: Unable to decrypt notification from collection cache!")
                continue
            }
            
            if let json = try? JSON(data: notificationMain) {
                guard let new = new(json: json) else { continue }
                
                if let lastUpdate = notificationRaw["lastUpdate"] as? Date, User.current?.userID == new.userID, !dateUpdated {
                    currentUpdateTime = lastUpdate
                    dateUpdated = true
                }

                if current[new.sender] != nil {
                    current[new.sender]?.append(new)
                } else {
                    current[new.sender] = [new]
                }
            } else {
                print("WARNING: Unable to parse decrypted notification main data as JSON!")
            }
        }
        
        for key in current.keys {
            current[key]!.sort { $0.creationDate <= $1.creationDate }
        }
    }
    
    static func saveLogoCache() {
        if !NSKeyedArchiver.archiveRootObject(cachedLogos, toFile: LOGO_CACHE) {
            print("WARNING: Unable to save notifications logo cache!")
        }
    }
    
    @discardableResult
    static func save() -> Bool {
        
        guard let currentUser = User.current else { return false }
        
        saveLogoCache()
        
        var collection = [[String : Any]]()
        
        for group in current.values {
            for n in group {
                var noRaw = [String : Any]()
                
                let mainEncrypted: Data? = NSData(data: try! n.encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)
                                
                noRaw["main"] = mainEncrypted
                noRaw["lastUpdate"] = currentUpdateTime
                
                collection.append(noRaw)
            }
        }
        
        cachedNotifications[currentUser.userID] = collection
                
        if NSKeyedArchiver.archiveRootObject(cachedNotifications, toFile: NOTIFICATIONS_PATH) {
            // print("Successfully wrote notification data for user (id = \(currentUser.userID)) to \(NOTIFICATIONS_PATH)")
            return true
        } else {
            return false
        }
    }
    
    var description: String {
        return shortString.string
    }
}

extension AccountNotification: Hashable {
    static func ==(lhs: AccountNotification, rhs: AccountNotification) -> Bool {
        return lhs.userID == rhs.userID && lhs.creationDate == rhs.creationDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
        hasher.combine(creationDate)
    }
    
    enum ContentType: String {
        case plain = "PLAIN"
        case newEvent = "NEW EVENT"
        case eventUpdate = "EVENT UPDATE"
        case newTicket = "NEW TICKET"
        case membershipInvite = "MEMBERSHIP INVITATION"
        case unsupported = ""
    }
    
    class Sender: Hashable, CustomStringConvertible {
        
        var name: String
        var senderID: String
        
        required init(name: String, id: String) {
            self.name = name
            self.senderID = id
        }
        
        static func ==(lhs: Sender, rhs: Sender) -> Bool {
            return lhs.senderID == rhs.senderID
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(senderID)
        }
        
        var description: String {
            return "Sender<\(senderID)>"
        }
        
        func markAsRead() {
            guard let userID = User.current?.userID else { return }
            
            let url = URL.with(base: PHP7_API_BASE_URL,
                               API_Name: "account/MarkNotificationsAsRead",
                               parameters: [
                                "userId": String(userID),
                                "senderId": senderID
                               ])!
            var request = URLRequest(url: url)
            request.addAuthHeader()
            
            let task = CUSTOM_SESSION.dataTask(with: request) {
                data, response, error in
                
                if error != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.markAsRead()
                    }
                }
                
            }
            
            task.resume()
        }
    }
}
