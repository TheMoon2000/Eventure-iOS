//
//  SettingSection.swift
//  Eventure
//
//  Created by Prince Wang on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
enum SettingSection: Int, CaseIterable, CustomStringConvertible {
    case Tags
    case ContactInfo
    
    var description: String {
        switch self {
        case .ContactInfo: return "Contact Info"
        case .Tags: return "Tags"
        }
    }
}

enum Tags: Int, CaseIterable, CustomStringConvertible {
    case tag1
    case tag2
    
    var description: String {
        switch self {
        case .tag1:
            return ""
        case .tag2:
            return ""
        }
    }
}

enum ContactInfoOptions:Int, CaseIterable, CustomStringConvertible {
    case email
    case phone
    case website
    case facebookPage
    
    var description: String {
        switch self {
        case .email: return "Email"
        case .phone: return "Phone"
        case .website: return "Website"
        case .facebookPage: return "Facebook Page"
        }
    }
}
