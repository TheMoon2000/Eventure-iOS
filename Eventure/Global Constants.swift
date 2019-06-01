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
let API_BASE_URL = "https://api.eventure-app.com/"

/// Credentials: DO NOT include when committing
let USERNAME = "__replace__"
let PASSWORD = "__replace__"

/// Todo: REPLACE THIS WITH THE APP's THEME COLOR

let MAIN_TINT2 = UIColor(red: 0.5, green: 0.7, blue: 0.92, alpha: 1)
let MAIN_TINT = UIColor(red: 127/255, green: 219/255, blue: 203/255, alpha: 1.0)
let MAIN_TINT_DARK = UIColor(red: 73/255, green: 188/255, blue: 167/255, alpha: 1)

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


/// Documents directory URL.
let DOCUMENTS_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

/// Cache directory URL.
let CACHES = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
