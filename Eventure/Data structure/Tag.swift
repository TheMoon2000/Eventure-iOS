//
//  Tag.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/10.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class Tag: Hashable, CustomStringConvertible {
    let id: Int
    let name: String
    var hasLogo: Bool?

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(id: String, name: String) {
        self.id = Int(id) ?? -1
        self.name = name
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func getLogo(_ handler: ((UIImage?) -> ())?) {
        if hasLogo == true {
            handler?(LocalStorage.tagImages[id])
            return
        }

        LocalStorage.getLogoForTag(id) { possibleImage in
            self.hasLogo = possibleImage != nil
            handler?(possibleImage)
        }
    }
    
    var description: String {
        return "Tag(id: \(id), name: '\(name)', hasLogo: \(String(describing: hasLogo)))"
    }
}
