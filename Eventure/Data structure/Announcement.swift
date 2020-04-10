//
//  Announcement.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/9.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class Announcement {
    let sender: String
    let title: String
    let content: String // Raw, unformatted markdown string
    let publishedDate: Date
    let link: URL?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        let contentJSON = JSON(parseJSON: dictionary["Content"]?.string ?? "").dictionaryValue
        
        sender = contentJSON["Sender"]?.string ?? "Unknown"
        title = contentJSON["Title"]?.string ?? ""
        content = contentJSON["Message"]?.string ?? "No content"
        
        if let rawDate = dictionary["Published date"]?.string {
            publishedDate = DATE_FORMATTER.date(from: rawDate) ?? .distantPast
        } else {
            publishedDate = .distantPast
        }
        
        link = contentJSON["Link"]?.url
    }
}
