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
    
    let showProfile: Bool

    let userID: Int
    let orgID: String
    let name: String
    let major: String
    
    let graduationYear: Int?
    let graduationSeason: User.GraduationSeason?
    
    let resume: String
    let linkedIn: String
    let github: String
    
    let interests: String
    let comments: String
    
    var profilePicture: UIImage?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        showProfile = (dictionary["Show profile"]?.int ?? 1) == 1
        userID = dictionary["User ID"]?.int ?? -1
        orgID = dictionary["Organization"]?.string ?? "Unknown Organization"
        name = dictionary["Name"]?.string ?? "<No Name>"
        major = dictionary["Major"]?.string ?? "Undecided"
        graduationYear = dictionary["Graduation year"]?.int
        graduationSeason = User.GraduationSeason(rawValue: dictionary["Graduation season"]?.string ?? "")
        resume = dictionary["Resume"]?.string ?? ""
        linkedIn = dictionary["LinkedIn"]?.string ?? ""
        github = dictionary["GitHub"]?.string ?? ""
        
        interests = dictionary["Interests"]?.string ?? ""
        comments = dictionary["Comments"]?.string ?? ""
    }
    
    /// Load the profile picture for a user.
    func getProfilePicture(_ handler: ((UserBrief) -> ())?) {
        if profilePicture != nil { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetProfilePicture",
                           parameters: ["userId": String(userID)])!
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
        return lhs.userID == rhs.userID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }

}
