//
//  Attendee.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class Attendee {
    
    /// The username of the attendee.
    let name: String
    
    /// The UUID of the event which this attendee has attended.
    let eventID: String
    
    /// The title of the event which this attendee has attended.
    let eventTitle: String
    
    /// The email of the attendee.
    let email: String
    
    /// The attendee's majors, represented by their IDs.
    let majors: [Major]
    let graduationYear: Int?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        var name = dictionary["Displayed name"]?.string ?? ""
        if name.isEmpty { name = dictionary["Full name"]?.string ?? "" }
        self.name = name
        
        email = dictionary["Email"]?.string ?? ""
        eventID = dictionary["Event ID"]?.string ?? ""
        eventTitle = dictionary["Event title"]?.string ?? ""
        graduationYear = dictionary["Graduation year"]?.int
        
        if let majorList = JSON(parseJSON: dictionary["Major"]!.stringValue).arrayObject as? [Int] {
            var tmp = [Major]()
            for majorIndex in majorList {
                if let major = LocalStorage.majors[majorIndex] {
                    tmp.append(major)
                }
            }
            majors = tmp
        } else {
            majors = []
        }
        
    }
    
}
