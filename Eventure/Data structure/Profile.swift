//
//  Profile.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

protocol Profile {
    
    var userID: Int { get }
    var name: String { get }
    var majorDescription: String { get }
    var shortMajorDescription: String { get }
    var email: String { get }
    
    var graduationYear: Int? { get }
    var graduationSeason: User.GraduationSeason? { get }
    
    var resume: String { get }
    var linkedIn: String { get }
    var github: String { get }
    
    var interests: String { get }
    var comments: String { get }
    
    var editable: Bool { get }
}

extension Profile {
    var graduation: String {
        if graduationYear == nil || graduationSeason == nil {
            return ""
        }
        return graduationSeason!.rawValue + " \(graduationYear!)"
    }
}

protocol EditableInfoProvider: UIViewController {
    var cellsEditable: Bool { get }
}
