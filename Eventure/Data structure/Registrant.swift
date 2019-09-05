//
//  Registrant.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// An overview of a user's professional profile.
class Registrant: Hashable, Profile {
    
    let showProfile: Bool
    let checkedInDate: Date

    var userID: Int
    var orgID: String
    var name: String
    var major: String
    var email: String
    
    let graduationYear: Int?
    let graduationSeason: User.GraduationSeason?
    
    let resume: String
    let linkedIn: String
    let github: String
    
    let interests: String
    let comments: String
    
    var profilePicture: UIImage?
    
    var editable: Bool { return false }
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        showProfile = (dictionary["Show profile"]?.int ?? 1) == 1
        userID = dictionary["User ID"]?.int ?? -1
        orgID = dictionary["Organization"]?.string ?? "Unknown Organization"
        name = dictionary["Full name"]?.string ?? "<No Name>"
        email = dictionary["Email"]?.string ?? "No email provided"
        major = dictionary["Major"]?.string ?? "Undecided"
        graduationYear = dictionary["Graduation year"]?.int
        graduationSeason = User.GraduationSeason(rawValue: dictionary["Graduation season"]?.string ?? "")
        resume = dictionary["Resume"]?.string ?? ""
        linkedIn = dictionary["LinkedIn"]?.string ?? ""
        github = dictionary["GitHub"]?.string ?? ""
        
        interests = dictionary["Interests"]?.string ?? ""
        comments = dictionary["Comments"]?.string ?? ""
        
        if let dateString = dictionary["Date"]?.string {
            checkedInDate = DATE_FORMATTER.date(from: dateString) ?? Date.distantFuture
        } else {
            checkedInDate = Date.distantFuture
        }
    }
    
    /// Load the profile picture for a user.
    func getProfilePicture(_ handler: ((Registrant) -> ())?) {
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
            
            self.profilePicture = UIImage(data: data!)
            if self.profilePicture != nil {
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
    }
    
    static func == (lhs: Registrant, rhs: Registrant) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }

}
