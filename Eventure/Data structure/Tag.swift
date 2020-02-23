//
//  Tag.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/10.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

struct Tag: Hashable {
    let id: Int
    let name: String
        
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
}
