//
//  Global Constants.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This file documents all global constants and configurations used by the app.

import UIKit
import SwiftyJSON

// MARK: - Global constants

/// The URL prefix for all the APIs
let API_BASE_URL = "https://api.eventure-app.com/"

/// Credentials: DO NOT include when committing
let USERNAME = "__replace__"
let PASSWORD = "__replace__"
let INTERNAL_ERROR = "internal error"

let USER_DEFAULT_CRED = "CREDENTIAL"
let USER_DEFAULT_TAB = "TAB"

/// Todo: REPLACE THIS WITH THE APP's THEME COLOR
let MAIN_TINT = UIColor(red: 1.0, green: 120/255, blue: 104/255, alpha: 1.0)
let MAIN_DISABLED = UIColor(red: 1.0, green: 179/255, blue: 168/255, alpha: 0.9)
let MAIN_TINT_DARK = UIColor(red: 230/255, green: 94/255, blue: 75/255, alpha: 1)
let LINE_TINT = UIColor.init(white: 0.9, alpha: 1)

let MAIN_TINT3 = UIColor(red: 133/255, green: 215/255, blue: 205/255, alpha: 1.0)

let MAIN_TINT6 = UIColor(red: 236/255, green: 110/255, blue: 173/255, alpha: 1.0)

let MAIN_TINT8 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)


/// Todo: REPLACE THIS WITH THE NAVIGATION BAR COLOR
let NAVBAR_TINT = UIColor(white: 0.93, alpha: 1)

/// Alpha value for disabled UI elements.
let DISABLED_ALPHA: CGFloat = 0.5

/// Custom URLSessionConfiguration with no caching
let CUSTOM_SESSION: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 5.0
    return URLSession(configuration: config)
}()

// MARK: - Classes and Extensions

class User: CustomStringConvertible {
    
    /// The current user, if the app is logged in.
    static var current: User?
    
    /// The UUID of the user.
    var uuid: Int
    var email: String
    var password_MD5: String
    var displayedName: String
    var gender: Gender
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

class Organization: CustomStringConvertible {
    static var current: Organization?
    
    var id: String?
    var title: String?
    var orgDescription: String?
    var website: String?
    var members = [String?]()
    var password_MD5: String?
    var tags = [String?]()
    var contactName: String?
    var contactEmail: String?
    var active: Bool?
    var dateRegistered: String?
    
    init(title: String) {
        self.title = title
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

class Event: CustomStringConvertible {
    static var current: Event?
    
    var id: String
    var title: String
    var location: String
    var time: String
    //var eventDescription: String
    //var eventVisual: UIImage?
    var host: Organization
    //var attendees = [User]()
    var tags = [String]()

    var active: Bool
    
    init(id: String, title: String, time: String, location: String, tags: [String], hostTitle: String) {
        self.id = id
        self.title = title
        self.time = time
        self.location = location
        self.tags = tags
        self.host = Organization(title: hostTitle)
        self.active = true
        //eventVisual = nil
        //eventDescription = "test"
    }
    
    init(eventInfo: JSON) {
        let dictionary = eventInfo.dictionary!
        
        id = dictionary["ID"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        location = dictionary["Location"]?.string ?? ""
        time = dictionary["Time"]?.string ?? ""
        //eventDescription = dictionary["Description"]?.string ?? ""
        let hostTitle = dictionary["Host"]?.string ?? ""
        host = Organization(title: hostTitle)
        
        /*let attendees_raw = { () -> [String] in
            var attendees_arr = [String]()
            for a in attendees {
                attendees_arr.append(a.email)
            }
            return attendees_arr
        }()
        
        if let attendees_raw = dictionary["Attendees"]?.string {
            let attendees_Email = (JSON(parseJSON: attendees_raw).arrayObject as? [String]) ?? [String]()
        }*/
        
        if let tags_raw = dictionary["Tags"]?.string {
            tags = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
        } else {
            tags = [String]()
        }
        
        
        active = (dictionary["Active"]?.int ?? 1) == 1
    }
    
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  id = \(id)\n"
        str += "  time = \(time)\n"
        str += "  @ = \(location)\n"
        str += "  tags = \(tags.description)"
        
        return str
    }
    
}

extension String {
    
    /// URL encode.
    var encoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    /// URL decode.
    var decoded: String {
        return self.removingPercentEncoding ?? self
    }
    
    /// Email verification method.
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

extension URL {
    
    /**
     Custom URL formatter.
     
     - Parameters:
        - base: The base / parent URL of the API.
        - API_Name: The API name.
        - parameters: The url parameters in the form of a Swift native dictionary.
     
     - Returns: An optional URL object (URL?) formed from the provided information.
     */
    
    static func with(base: String, API_Name: String, parameters: [String: String]) -> URL? {
        if (parameters.isEmpty) {
            return URL(string: base + API_Name)
        }
        let formattedParameters = parameters.map {
            return $0.key.encoded + "=" + $0.value.encoded
        }
        return URL(string: "\(base + API_Name)?" + formattedParameters.joined(separator: "&"))
    }
}

extension URLRequest {
    
    /// Add a basic authorization header for the current request.
    mutating func addAuthHeader() {
        let token = "\(USERNAME):\(PASSWORD)".data(using: .utf8)!.base64EncodedString()
        self.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    }
    
    /// Add multipart data to the request.
    mutating func addMultipartBody(parameters: [String : String], files: [String: Data] = [:]) {
        
        // Build the body data
        
        let boundary = "----Eventure-API-Multipart-Boundary"
        let prefix = "--" + boundary + "\r\n"
        
        var data = Data()
        
        for parameter in parameters {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(parameter.key)\"\r\n\r\n")
            data.append(string: parameter.value + "\r\n")
        }
        
        for file in files {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(file.key)\"\r\n")
            data.append(string: "Content-Type: image/png\r\n\r\n")
            data.append(file.value)
            data.append(string: "\r\n")
        }
        
        data.append(string: "--" + boundary + "--")
        
        // Begin mutating the request
        self.addValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        self.httpBody = data
    }
}

extension UITextField {
    func doInset() {
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = inset
        self.leftViewMode = .always
    }
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: .utf8)!
        append(data)
    }
}

/// Documents directory URL.
let DOCUMENTS_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

/// Cache directory URL.
let CACHES = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]


// MARK: - Standard alerts

func serverMaintenanceError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: "Expected Error", message: "Oops, looks like our server is unavailable or under maintenance. We're very sorry for the inconvenience and we hope that you will come back later.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    
    vc.present(alert, animated: true, completion: nil)
}

func internetUnavailableError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    alert.title = "Unable to Connect"
    alert.message = "Please check your internet connection."
    alert.addAction(.init(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    vc.present(alert, animated: true, completion: nil)
}
