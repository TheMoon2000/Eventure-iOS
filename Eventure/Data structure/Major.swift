//
//  Major.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class Major {
    
    var id: Int
    var fullName: String
    var abbreviation: String?
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        id = dictionary["id"]?.int ?? -1
        fullName = dictionary["Full name"]?.string ?? "Unknown"
        abbreviation = dictionary["Abbreviation"]?.string
    }
    
    var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["id"] = id
        json.dictionaryObject?["Full name"] = fullName
        json.dictionaryObject?["Abbreviation"] = abbreviation
        
        return json
    }
    
}


extension Major: Hashable {
    
    static func ==(lhs: Major, rhs: Major) -> Bool {
        return lhs.fullName.lowercased() == rhs.fullName.lowercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fullName.lowercased())
    }
    
}
