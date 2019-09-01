//
//  Campus.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Campus {

    static var supported = [Campus]()
    
    /// The full name of the location.
    let fullName: String
    
    /// e.g. 'Cal'.
    let abbreviation: String
    
    /// e.g. 'berkeley.edu'.
    let emailSuffix: String
    
    let longitude: Double
    let latitude: Double
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        fullName = dictionary["Name"]?.string ?? "Unknown"
        abbreviation = dictionary["Abbreviation"]?.string ?? ""
        emailSuffix = dictionary["Email suffix"]?.string ?? "berkeley.edu"
        longitude = dictionary["Longitude"]?.double ?? -122.26
        latitude = dictionary["Latitude"]?.double ?? 37.87
    }
}
