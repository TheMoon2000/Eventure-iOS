//
//  UserRegistrationData.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

struct UserRegistrationData {

    var email = "" {
        didSet {
            emailVerified = false
        }
    }
    var emailVerified = false
    var password = ""
    var retype = ""
    var displayName = ""
    var gender = -1
    
    var isValid: Bool {
        if !emailVerified { return false }
        if password != retype { return false }
        if password.count < 8 { return false }
        if displayName.count > 255 { return false }
        return true
    }
    
    var parameters: [String: String] {
        var p = [String: String]()
        p["email"] = email
        p["password"] = password
        p["displayedName"] = displayName
        p["gender"] = gender.description
        
        return p
    }
    
}
