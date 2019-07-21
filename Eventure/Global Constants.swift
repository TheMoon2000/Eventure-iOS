//
//  Global Constants.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This file documents all global constants used by the app
import UIKit

/// The URL prefix for all the APIs
let API_BASE_URL = "https://api.eventure-app.online/"

/// Credentials: DO NOT include when committing
let USERNAME = "__replace__"
let PASSWORD = "__replace__"

/// Todo: REPLACE THIS WITH THE APP's THEME COLOR
let MAIN_TINT2 = UIColor(red: 0.5, green: 0.7, blue: 0.92, alpha: 1)
let MAIN_TINT = UIColor(red: 1.0, green: 127/255, blue: 114/255, alpha: 1.0)
let MAIN_TINT_DARK = UIColor(red: 73/255, green: 188/255, blue: 167/255, alpha: 1)

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

/// Initialize new URL with url parameters
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

extension UITextField {
    func doInset() {
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = inset
        self.leftViewMode = .always
    }
}
/// Documents directory URL.
let DOCUMENTS_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

/// Cache directory URL.
let CACHES = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
