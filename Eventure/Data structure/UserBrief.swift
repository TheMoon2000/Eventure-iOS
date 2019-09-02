//
//  UserBrief.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// An overview of a user's professional profile.
class UserBrief: Hashable {
    
    let uuid: Int
    let name: String
    let major: String?
    var profilePicture: UIImage?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        uuid = dictionary["uuid"]?.int ?? -1
        name = dictionary["Name"]?.string ?? "<No Name>"
        major = dictionary["Major"]?.string ?? "Undecided"
    }
    
    /// Load the profile picture for a user.
    func getProfilePicture(_ handler: ((UserBrief) -> ())?) {
        if profilePicture != nil { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetProfilePicture",
                           parameters: ["userId": String(uuid)])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                handler?(self)
                return // Don't display any alert here
            }
            
            self.profilePicture = UIImage(data: data!) ?? #imageLiteral(resourceName: "user_default")
            DispatchQueue.main.async {
                handler?(self)
            }
        }
        
        task.resume()
    }
    
    static func == (lhs: UserBrief, rhs: UserBrief) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

}
