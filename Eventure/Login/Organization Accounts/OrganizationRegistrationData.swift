//
//  OrganizationRegistrationData.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/5.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

struct OrganizationRegistrationData {
    
    var title = ""
    var website = ""
    var tags = "" // Tags are stored in string format
    var logo: UIImage?
    var orgID = "" {
        didSet {
            orgIDVerified = false
        }
    }
    var orgIDVerified = false
    var password = ""
    var retype = ""
    var contactName = ""
    var contactEmail = ""
    
    var isValid: Bool {
        
        // Check non-blank
        if [title, tags, orgID, contactName, contactEmail].contains(where: { blank($0) }) {
            return false
        }
        
        // Varchar cannot exceed 255 characters in a MySQL database
        if [title, tags, orgID, contactName, contactEmail, website].contains(where: { $0.count > 255 }) {
            return false
        }
        
        if password != retype { return false }
        if password.count < 8 { return false }
        if !orgIDVerified { return false }
        if !contactEmail.isValidEmail() { return false }
        
        return true
    }
    
    var parameters: [String: String] {
        return [
            "id": orgID,
            "password": password,
            "title": title,
            "website": website,
            "tags": tags,
            "name": contactName,
            "email": contactEmail
        ]
    }
    
    var fileData: [String: Data] {
        if let pngData = logo?.pngData() {
            return ["logo": pngData]
        } else {
            return [:]
        }
    }
    
    private func blank(_ string: String) -> Bool {
        return CharacterSet(charactersIn: string).isSubset(of: .whitespaces)
    }
}
