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
let MAIN_TINT4 = UIColor(red: 28/255, green: 239/255, blue: 255/255, alpha: 1.0)

let MAIN_TINT5 = UIColor(red: 0/255, green: 203/255, blue: 223/255, alpha: 1.0)
let MAIN_TINT6 = UIColor(red: 236/255, green: 110/255, blue: 173/255, alpha: 1.0)
let MAIN_TINT7 = UIColor(red: 52/255, green: 147/255, blue: 230/255, alpha: 1.0)
let MAIN_TINT8 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)
let MAIN_TINT9 = UIColor(red: 255/255, green: 94/255, blue: 98/255, alpha: 1.0)

let MAIN_TINT10 = UIColor(red: 255/255, green: 128/255, blue: 8/255, alpha: 1.0)
let MAIN_TINT11 = UIColor(red: 255/255, green: 200/255, blue: 55/255, alpha: 1.0)

let MAIN_TINT12 = UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0)
let MAIN_TINT13 = UIColor(red: 240/255, green: 152/255, blue: 25/255, alpha: 1.0)

let MAIN_TINT14 = UIColor(red: 242/255, green: 153/255, blue: 74/255, alpha: 1.0)
let MAIN_TINT15 = UIColor(red: 252/255, green: 211/255, blue: 86/255, alpha: 1.0)

let MAIN_TINT16 = UIColor(red: 255/255, green: 179/255, blue: 71/255, alpha: 1.0)
let MAIN_TINT17 = UIColor(red: 255/255, green: 204/255, blue: 51/255, alpha: 1.0)

let MAIN_TINT18 = UIColor(red: 103/255, green: 178/255, blue: 111/255, alpha: 1.0)
let MAIN_TINT19 = UIColor(red: 76/255, green: 162/255, blue: 205/255, alpha: 1.0)

let MAIN_TINT20 = UIColor(red: 118/255, green: 184/255, blue: 82/255, alpha: 1.0)
let MAIN_TINT21 = UIColor(red: 141/255, green: 194/255, blue: 111/255, alpha: 1.0)

/// Todo: REPLACE THIS WITH THE NAVIGATION BAR COLOR
let NAVBAR_TINT = UIColor(white: 0.93, alpha: 1)

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
