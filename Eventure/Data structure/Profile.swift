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
    var majors: Set<Int> { get }
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
    
    var majorDescription: String {
        let objects = majors.map { LocalStorage.majors[$0]?.fullName } .filter { $0 != nil } . map { $0! }
        
        if objects.isEmpty {
            return "Undeclared"
        }
        
        return objects.joined(separator: " + ")
    }
    
    var shortMajorDescription: String {
        let objects = majors.map { LocalStorage.majors[$0]?.abbreviation ?? LocalStorage.majors[$0]?.fullName } .filter { $0 != nil } . map { $0! }
        
        if objects.isEmpty {
            return "Undeclared"
        }
        
        return objects.joined(separator: " + ")
    }
}

protocol EditableInfoProvider: UIViewController {
    var cellsEditable: Bool { get }
}
