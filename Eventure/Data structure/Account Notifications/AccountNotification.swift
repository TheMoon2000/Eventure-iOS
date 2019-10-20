//
//  AccountNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class AccountNotification {
    
    static var cachedNotifications = [Int: [[String: Any]]]()
    
    let userID: Int
    let title: String
    var creationDate: Date
    let rawContent: JSON
    let type: ContentType
    let senderOrg: String?
    var senderLogo: UIImage?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        self.userID = dictionary["User ID"]?.int ?? -1
        self.title = dictionary["Title"]?.string ?? ""
        self.creationDate = PRECISE_FORMATTER.date(from: dictionary["Date"]!.string!) ?? .distantPast
        self.type = ContentType(rawValue: dictionary["Type"]!.string!) ?? .plain
        self.rawContent = dictionary["Content"]!
        self.senderOrg = dictionary["Sender"]?.string
        getLogoImage(nil)
    }
    
    static func new(json: JSON) -> AccountNotification? {
        let dictionary = json.dictionaryValue
        guard let typeString = dictionary["Type"]?.string else { return nil }
        guard dictionary["Date"] != nil else { return nil }
        let type = ContentType(rawValue: typeString)
        switch type {
        case .event:
            return EventNotification(json: json)
        default:
            return AccountNotification(json: json)
        }
    }
    
    /// Load the logo image for the sender organization.
    func getLogoImage(_ handler: ((AccountNotification) -> ())?) {
        
        guard let orgID = senderOrg else {
            senderLogo = #imageLiteral(resourceName: "user_default")
            handler?(self)
            return
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": orgID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in

            guard error == nil else {
                print("WARNING: Get logo image returned error for organization!")
                return // Don't display any alert here
            }
            
            if let newLogo = UIImage(data: data!), self.senderLogo != newLogo {
                self.senderLogo = newLogo
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }

        task.resume()
    }
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["User ID"] = userID
        json.dictionaryObject?["Title"] = title
        json.dictionaryObject?["Type"] = type.rawValue
        json.dictionaryObject?["Date"] = PRECISE_FORMATTER.string(from: creationDate)
        json.dictionaryObject?["Content"] = rawContent.rawString([.castNilToNSNull: true])!
        
        return json
    }
    
    static func readFromFile() -> [Int: Set<AccountNotification>] {
        
        var allNotifications = [Int: Set<AccountNotification>]()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: NOTIFICATIONS_PATH) else {
            return [:] // It's fine if no event collection cache exists.
        }
        
        guard let collection = fileData as? [Int: [[String: Any]]] else {
            print("WARNING: Cannot read notification collection at \(NOTIFICATIONS_PATH)!")
            return [:]
        }
                
        cachedNotifications = collection
        
        for (userID, notifications) in collection {
            for notificationRaw in notifications {
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
                    var userSpecific: Set<AccountNotification> = allNotifications[userID] ?? []

                    new.senderLogo = notificationRaw["logo"] as? UIImage
                    userSpecific.insert(new)
                    
                    allNotifications[userID] = userSpecific
                } else {
                    print("WARNING: Unable to parse decrypted notification main data as JSON!")
                }
            }
        }
        
        return allNotifications
    }
    
    
    static func writeToFile(userID: Int, notifications: Set<AccountNotification>) -> Bool {
        
        var collection = [[String : Any]]()
        
        for n in notifications {
            var noRaw = [String : Any]()
            
            let mainEncrypted: Data? = NSData(data: try! n.encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)
            
            noRaw["main"] = mainEncrypted
            noRaw["logo"] = n.senderLogo
            
            collection.append(noRaw)
        }
        
        cachedNotifications[userID] = collection
                
        if NSKeyedArchiver.archiveRootObject(cachedNotifications, toFile: NOTIFICATIONS_PATH) {
            return true
        } else {
            return false
        }
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
        case event = "EVENT"
        case eventUpdate = "EVENT UPDATE"
        case newTicket = "NEW TICKET"
    }
}
