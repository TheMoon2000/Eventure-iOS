//
//  UserBrief.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserBrief {
    
    let uuid: Int
    let name: String
    let major: String?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        uuid = dictionary["uuid"]?.int ?? -1
        name = dictionary["Name"]?.string ?? "<No Name>"
        major = dictionary["Major"]?.string
    }
}
