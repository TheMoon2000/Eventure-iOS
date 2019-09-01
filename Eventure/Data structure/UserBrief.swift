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
    var profilePicture: UIImage?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        uuid = dictionary["uuid"]?.int ?? -1
        name = dictionary["Name"]?.string ?? "<No Name>"
        major = dictionary["Major"]?.string
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

}
