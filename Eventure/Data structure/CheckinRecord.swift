//
//  CheckinRecord.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckinRecord: Hashable {

    let userID: Int
    let sheetID: String
    let showProfile: Bool
    let checkedInDate: Date
    let orgID: String
    let eventTitle: String
    let orgTitle: String
    let hasCover: Bool
    
    var coverImage: UIImage?
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        userID = dictionary["User ID"]?.int ?? -1
        sheetID = dictionary["Sheet ID"]?.string ?? ""
        orgID = dictionary["Organization"]?.string ?? ""
        showProfile = (dictionary["Show profile"]?.int ?? 1) == 1
        if let dateString = dictionary["Date"]?.string {
            checkedInDate = DATE_FORMATTER.date(from: dateString) ?? Date.distantFuture
        } else {
            checkedInDate = Date.distantFuture
        }
        eventTitle = dictionary["Title"]?.string ?? "Untitled Event"
        orgTitle = dictionary["Organization title"]?.string ?? "Untitled Organization"
        hasCover = (dictionary["Has cover"]?.int ?? 0) == 1
    }
    
    /// Load the cover image for an event.
    func getCover(_ handler: ((CheckinRecord) -> ())?) {
        if !hasCover || coverImage != nil { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventCover",
                           parameters: ["uuid": sheetID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.coverImage = UIImage(data: data!)
            DispatchQueue.main.async {
                handler?(self)
            }
        }
        
        task.resume()
    }
    
    static let lastestFirst: ((CheckinRecord, CheckinRecord) -> Bool) = { e1, e2 in
        return e1.checkedInDate >= e2.checkedInDate
    }
    
    static let oldestFirst: ((CheckinRecord, CheckinRecord) -> Bool) = { e1, e2 in
        return e1.checkedInDate <= e2.checkedInDate
    }
    
    
    // MARK: - Hashable
    
    static func ==(lhs: CheckinRecord, rhs: CheckinRecord) -> Bool {
        return lhs.sheetID == rhs.sheetID && lhs.userID == rhs.userID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sheetID)
        hasher.combine(userID)
    }
}
