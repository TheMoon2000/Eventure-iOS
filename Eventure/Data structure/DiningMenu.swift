//
//  DiningMenu.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/25.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

let SPECIAL_NAMES = ["LOC", "DAY", "IS_OPEN", "MSG"]

class DiningMenu {
    let location: String
    let isOpen: Bool
    let day: Int
    let message: String?
    var menuItems = [String: [DiningItem]]()
    var mealTime: Int { -1 } // Should be overwritten.
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue

        location = dictionary["LOC"]?.string ?? "Error"
        isOpen = dictionary["IS_OPEN"]?.int == 1
        message = dictionary["MSG"]?.string
        day = dictionary["DAY"]?.int ?? 0
        
        for (categoryName, info) in dictionary {
            
            if SPECIAL_NAMES.contains(categoryName) { continue }

            var dishes = [DiningItem]()
            
            for (name, options) in JSON(parseJSON: info.stringValue).dictionaryValue {
                dishes.append(.init(name: name, category: categoryName, options: options))
            }
            
            if !dishes.isEmpty {
                menuItems[categoryName] = dishes
            }
        }
    }

    /// Number of sections to display for the dining menu.
    var numberOfHeadings: Int { menuItems.count }
    
    var diningItems: [(name: String, items: [DiningItem])] {
        return menuItems.sorted { (pair1, pair2) -> Bool in
            return pair1.key < pair2.key
        }.map { (name: $0.key, items: $0.value) }
    }
}

class BreakfastMenu: DiningMenu {
        
    override var mealTime: Int { 0 }
    
}

class LunchDiningMenu: DiningMenu {
        
    override var mealTime: Int { 1 }
    
}

class DinnerDiningMenu: DiningMenu {
    
    override var mealTime: Int { 2 }
    
}
