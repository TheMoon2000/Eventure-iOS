//
//  NewEventNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewEventNotification: AccountNotification {
    
    var eventID = ""
    var eventTitle = ""
    var startTime: Date!
    var location = ""
    var eventSummary = ""
    var coverImage: UIImage?
    
    override var contentType: AccountNotification.ContentType {
        return .newEvent
    }
    
    override var shortString: NSAttributedString {
        return NSAttributedString.composed(of: [
            "New event: ".styled(with: .basicStyle),
            eventTitle.styled(with: .valueStyle)
        ])
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.eventTitle = rawContent.dictionary?["eventTitle"]?.string?.decoded ?? ""
        self.eventID = rawContent.dictionary?["eventId"]?.string?.decoded ?? ""
        self.startTime = DATE_FORMATTER.date(from: rawContent.dictionary?["startTime"]?.string ?? "") ?? Date.init(timeIntervalSinceReferenceDate: 0)
        self.location = rawContent.dictionary?["location"]?.string?.decoded ?? "TBA"
        self.eventSummary = rawContent.dictionary?["description"]?.string?.decoded ?? "No description."
        self.coverImage = AccountNotification.cachedLogos[eventID]
    }
    
    /// Load the cover image for the event.
    func getCover(_ handler: ((NewEventNotification) -> ())?) {
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventCover",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.coverImage = UIImage(data: data!)
            if self.coverImage != nil {
                AccountNotification.cachedLogos[self.eventID] = self.coverImage
                AccountNotification.saveLogoCache()
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
    }
    
    /// Update the event info regularly to prevent displaying outdated information.
    func synchronize() {
        
    }
}
