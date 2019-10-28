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

    static var current: Organization? {
        didSet (oldValue) {
            if current != nil {
                UserDefaults.standard.setValue(ACCOUNT_TYPE_ORG, forKey: KEY_ACCOUNT_TYPE)
                current?.save(requireReupload: false)
                current?.saveEnabled = true
            }
        }
    }

    let id: String
    var title: String { didSet { save() } }
    var password_MD5: String { didSet { save() } }
    var active: Bool { didSet { save() } }
    var dateRegistered: String { didSet { save() } }
    var logoImage: UIImage? { didSet { save(requireReupload: false) } }
    var hasLogo: Bool
    var subscribers = Set<Int>() { didSet { save() } }
    var roles = Set<String>() { didSet { save() } }
    var departments = Set<String>() { didSet { save() } }
    var members = Set<Membership>() { didSet { save() } }
    var numberOfEvents = 0

    // Profile Information
    var contactName: String { didSet { save() } }
    var tags = Set<String>() { didSet { save() } }
    var website: String { didSet { save() } }
    var contactEmail: String { didSet { save() } }
    var orgDescription: String { didSet { save(requireReupload: false) } }

    var saveEnabled: Bool = false

    static var empty: Organization {
        return Organization(title: "")
    }

    /// Whether the app is in the middle of a sync session and is waiting for a response.
    static var waitingForSync = false

    /// Whether the changes made locally are yet to be uploaded.
    static var needsUpload = false

    var profileStatus: String {
        var allEmpty = true
        for item in [website, contactEmail, orgDescription, contactName] {
            allEmpty = allEmpty && item.isEmpty
        }
        allEmpty = allEmpty && tags.isEmpty

        if allEmpty { return "Not Started" }

        var filledRequirements = true
        for item in [contactName] {
            filledRequirements = filledRequirements && !item.isEmpty
        }
        allEmpty = allEmpty && tags.isEmpty

        if filledRequirements {
            return "Completed"
        } else {
            return "Incomplete"
        }

    }

    init(title: String) {
        id = title
        self.title = title
        orgDescription = ""
        website = ""
        password_MD5 = ""
        tags = []
        contactName = ""
        contactEmail = ""
        active = true
        dateRegistered = ""
        hasLogo = false
    }

    init(orgInfo: JSON) {
        let dictionary = orgInfo.dictionary!

        id = dictionary["ID"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        orgDescription = dictionary["Description"]?.string ?? ""
        website = dictionary["Website"]?.string ?? ""

        if let tags_raw = dictionary["Tags"]?.string {
            let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
            tags = Set(tagsArray)
        }
        
        if let roles_raw = dictionary["Roles"]?.string {
            let rolesArray = (JSON(parseJSON: roles_raw).arrayObject as? [String]) ?? [String]()
            roles = Set(rolesArray)
        }
        
        if let dept_raw = dictionary["Departments"]?.string {
            let deptArray = (JSON(parseJSON: dept_raw).arrayObject as? [String]) ?? [String]()
            departments = Set(deptArray)
        }
                
        for memInfo in (dictionary["Members"]?.arrayValue ?? []) {
            members.insert(Membership(memberInfo: memInfo))
        }

        password_MD5 = dictionary["Password MD5"]?.string ?? ""
        contactName = dictionary["Contact name"]?.string ?? ""
        contactEmail = dictionary["Email"]?.string ?? ""
        active = (dictionary["Active"]?.int ?? 1) == 1
        dateRegistered = dictionary["Date registered"]?.string ?? ""
        hasLogo = (dictionary["Has logo"]?.int ?? 0) == 1
        numberOfEvents = dictionary["# of events"]?.int ?? 0

        if let subscribers_raw = dictionary["Subscribers"]?.string {
            if let subArray = JSON(parseJSON: subscribers_raw).arrayObject as? [Int] {
                subscribers = Set(subArray)
            }
        }
    }

    var description: String {
        var str = "Organization (\"\(String(describing: title))\":\n"
        str += "  id = \(String(describing: id))\n"
        str += "  website = \(String(describing: website))\n"
        str += "  tags = \(tags.description)\n"
        str += "  date registered = \(String(describing: dateRegistered))\n"
        str += "  # of subscribers = \(subscribers.count))"

        return str
    }

    static func cachedOrgAccount(at path: String) -> Organization? {
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [String: Any] else { return nil }
        
        guard let mainData = fileData["main"] as? Data else {
            print("WARNING: Key `main` not found for cached organization account!")
            return nil
        }
        
        guard let decryptedMain = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
            print("WARNING: Unable to decrypt organization from main cache!")
            return nil
        }
        
        guard let json = try? JSON(data: decryptedMain) else {
            print("WARNING: Cannot read main cache as JSON!")
            return nil
        }
        
        let newOrg = Organization(orgInfo: json)
        guard !newOrg.title.isEmpty else {
            print(json)
            print("WARNING: Damaged data was read from cache!")
            return nil
        }
        
        if let image = fileData["logo"] as? UIImage {
            newOrg.logoImage = image
        } else {
            print("WARNING: No org logo image found or cannot be read")
        }
        
        return newOrg
    }

    /// Short-cut for writeToFile().
    func save(requireReupload: Bool = true) {
        if self.id != Organization.current?.id { return }

        if requireReupload {
            Organization.needsUpload = true
        }
        
        if writeToFile(path: CURRENT_USER_PATH) == false {
            print("WARNING: cannot write organization to \(CURRENT_USER_PATH)")
        } else {
            print("successfully wrote organization to \(CURRENT_USER_PATH)")
        }
    }
    
    /**
     Uploads the current organization settings to the server.
     
     - Parameters:
        - settings: The set of settings that should be updated.
        - handler: Optional handler that will be called after this method attempts to upload the organization settings.
     */
    
    func pushSettings(_ settings: PushableSettings, _ handler: ((Bool) -> ())? = nil) {
        var body = JSON()
        
        if settings.contains(.orgTitle) {
            body.dictionaryObject?["Title"] = title
        }
        
        if settings.contains(.email) {
            body.dictionaryObject?["Email"] = contactEmail
        }
        
        if settings.contains(.orgDescription) {
            body.dictionaryObject?["Description"] = orgDescription
        }
        
        if settings.contains(.tags) {
            body.dictionaryObject?["Tags"] = tags.description
        }
        
        if settings.contains(.website) {
            body.dictionaryObject?["Website"] = website
        }
        
        if settings.contains(.roles) {
            body.dictionaryObject?["Roles"] = roles.description
        }
        
        if settings.contains(.departments) {
            body.dictionaryObject?["Departments"] = departments.description
        }
        
        pushToServer(handler, customJSON: body)
    }
    
    /// Now made private to prevent direct calling. Push operations should be done using the above method.
    private func pushToServer(_ handler: ((Bool) -> ())?, customJSON: JSON) {
                
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/UpdateOrgInfo",
                           parameters: ["id": id])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        request.httpMethod = "POST"
        request.httpBody = try? customJSON.rawData()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            if String(data: data!, encoding: .utf8) == "success" {
                Organization.needsUpload = false
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
    
    
    private func encodedJSON() -> JSON {
        var json = JSON()
        json.dictionaryObject?["ID"] = self.id
        json.dictionaryObject?["Title"] = self.title
        json.dictionaryObject?["Description"] = self.orgDescription
        json.dictionaryObject?["Website"] = self.website
        json.dictionaryObject?["Tags"] = self.tags.description
        json.dictionaryObject?["Roles"] = self.roles.description
        json.dictionaryObject?["Password MD5"] = self.password_MD5
        json.dictionaryObject?["Contact name"] = self.contactName
        json.dictionaryObject?["Email"] = self.contactEmail
        json.dictionaryObject?["Active"] = self.active ? 1 : 0
        json.dictionaryObject?["Date registered"] = self.dateRegistered
        json.dictionaryObject?["Has logo"] = self.hasLogo ? 1 : 0
        json.dictionaryObject?["Subscribers"] = self.subscribers.description
        json.dictionaryObject?["Members"] = members.map { $0.encodedJSON }
        json.dictionaryObject?["Departments"] = departments.description
        json.dictionaryObject?["Roles"] = roles.description
        
        return json
    }
    
    func writeToFile(path: String) -> Bool {
        
        var fileData = [String: Any]()

        var json = encodedJSON()
        json.dictionaryObject?["# of events"] = self.numberOfEvents
        
        try? FileManager.default.createDirectory(at: ACCOUNT_DIR, withIntermediateDirectories: true, attributes: nil)

        fileData["main"] = NSData(data: try! json.rawData()).aes256Encrypt(withKey: AES_KEY)!
        fileData["logo"] = logoImage
        
        return NSKeyedArchiver.archiveRootObject(fileData, toFile: CURRENT_USER_PATH)
    }

    /// Load the logo image for an organization.
    func getLogoImage(_ handler: ((Organization) -> ())?) {
        if !hasLogo { return }

        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in

            guard error == nil else {
                print("WARNING: Get logo image returned error for organization!")
                return // Don't display any alert here
            }
            if let newLogo = UIImage(data: data!), self.logoImage != newLogo {
                self.logoImage = newLogo
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }

        task.resume()
    }


    /// Sync the local organization account data with the server's.
    static func syncFromServer() {
        if Organization.current == nil { return }
        
        var parameters = ["orgId": Organization.current!.id]
        parameters["token"] = User.token
        parameters["build"] = Bundle.main.infoDictionary?[kCFBundleVersionKey! as String] as? String
        
        Organization.waitingForSync = true
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in

            Organization.waitingForSync = false
            
            guard error == nil else {
                print(error!)
                NotificationCenter.default.post(name: ORG_SYNC_FAILED, object: nil)
                return
            }

            if let json = try? JSON(data: data!) {
                let currentLogo = Organization.current?.logoImage
                Organization.current = Organization(orgInfo: json)
                Organization.current?.logoImage = currentLogo
                NotificationCenter.default.post(name: ORG_SYNC_SUCCESS, object: nil)
            } else {
                print("WARNING: cannot parse '\(String(data: data!, encoding: .utf8)!)'")
                NotificationCenter.default.post(name: ORG_SYNC_FAILED, object: nil)
            }
        }

        task.resume()
    }
    
    static func getOrganization(with orgID: String, _ handler: @escaping ((Organization?) -> ())) {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: ["orgId": orgID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler(nil)
                }
                return
            }
            
            if let orgInfo = try? JSON(data: data!) {
                handler(Organization(orgInfo: orgInfo))
            } else {
                DispatchQueue.main.async {
                    handler(nil)
                }
            }
        }
        
        task.resume()
    }
    
    func uploadLogo(new: UIImage, _ handler: ((Bool) -> ())?) {
        
        let original = logoImage
        logoImage = new.sizeDown(maxWidth: 500)
        
        let url = URL(string: API_BASE_URL + "account/UploadLogo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = ["id": id]
        
        var fileData = [String : Data]()
        fileData["logo"] = new.sizeDownData(maxWidth: 500)
        
        request.addMultipartBody(parameters: parameters as [String : String],
                                 files: fileData)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                self.logoImage = original
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)!
            switch msg {
            case INTERNAL_ERROR:
                self.logoImage = original
                handler?(false)
            case "success":
                print("Org logo updated")
                self.logoImage = new
                DispatchQueue.main.async {
                    handler?(true)
                }
            default:
                self.logoImage = original
                print(msg)
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    /// Update the members for this organization. The handler should handle whether the update was successful.
    func updateMembers(_ handler: ((Bool) -> ())?) {
        
        Organization.waitingForSync = true
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: ["orgId": id])!
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

            if let json = try? JSON(data: data!) {
                let newOrg = Organization(orgInfo: json)
                self.members = newOrg.members
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

}

extension Organization: Hashable {
    static func == (lhs: Organization, rhs: Organization) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Organization {
    struct PushableSettings: OptionSet {
        let rawValue: Int
        
        static let orgDescription   = PushableSettings(rawValue: 1)
        static let tags             = PushableSettings(rawValue: 1 << 1)
        static let orgTitle         = PushableSettings(rawValue: 1 << 2)
        static let email            = PushableSettings(rawValue: 1 << 3)
        static let website          = PushableSettings(rawValue: 1 << 4)
        static let roles            = PushableSettings(rawValue: 1 << 5)
        static let departments      = PushableSettings(rawValue: 1 << 6)
    }
}
