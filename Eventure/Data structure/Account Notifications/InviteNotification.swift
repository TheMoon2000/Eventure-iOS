//
//  InviteNotification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A subclass of user account notifications that presents a club membership invitation.
class InviteNotification: AccountNotification {
    var role = ""
    var status = Status.pending
    
    override var type: AccountNotification.ContentType {
        return .membershipInvite
    }
    
    override var shortString: NSAttributedString {
        return "[Member invitation: \(role)]".styled(with: .basicStyle)
    }
    
    override init(json: JSON) {
        super.init(json: json)
        
        self.role = rawContent.dictionary?["role"]?.string?.decoded ?? ""
        self.status = Status(rawValue: rawContent.dictionary?["status"]?.int ?? 0) ?? .pending
    }
    
    func pushStatus() {
        let url = URL.with(base: PHP7_API_BASE_URL,
                           API_Name: "account/UpdateInvitationStatus",
                           parameters: [
                            "date": PRECISE_FORMATTER.string(from: creationDate),
                            "accept": String(status.rawValue)
                           ])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.pushStatus()
                }
                return
            }
        }
        
        task.resume()
    }
    
    enum Status: Int {
        case accepted = 1
        case pending = 0
        case declined = -1
    }
}
