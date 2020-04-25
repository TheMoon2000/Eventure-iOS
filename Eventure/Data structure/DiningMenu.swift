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
    }

    var numberOfHeadings: Int {
        return 0
    }
    
    var diningItems: [(name: String, items: [DiningItem])] {
        return menuItems.sorted { (pair1, pair2) -> Bool in
            return pair1.key < pair2.key
        }.map { (name: $0.key, items: $0.value) }
    }
}

class BreakfastMenu: DiningMenu {
        
    override var mealTime: Int { 0 }
    
    override init(json: JSON) {
        super.init(json: json)

        let dictionary = json.dictionaryValue
                
        for (categoryName, info) in dictionary {
            
            var dishes = [DiningItem]()
            
            if SPECIAL_NAMES.contains(categoryName) { continue }
            
            for (name, options) in JSON(parseJSON: info.stringValue).dictionaryValue {
                dishes.append(.init(name: name, category: categoryName, options: options))
            }
            
            if !dishes.isEmpty {
                menuItems[categoryName] = dishes
            }
        }
        
    }
    
}

class LunchDiningMenu: DiningMenu {
        
    override var mealTime: Int { 1 }
    
    override init(json: JSON) {
        super.init(json: json)
        
        let dictionary = json.dictionaryValue
                
        for (categoryName, info) in dictionary {
            
            var dishes = [DiningItem]()
            
            if SPECIAL_NAMES.contains(categoryName) { continue }
            
            for (name, options) in JSON(parseJSON: info.stringValue).dictionaryValue {
                dishes.append(.init(name: name, category: categoryName, options: options))
            }
            
            if !dishes.isEmpty {
                menuItems[categoryName] = dishes
            }
        }

    }
    
}

class DinnerDiningMenu: DiningMenu {
    
    override var mealTime: Int { 2 }
    
    override init(json: JSON) {
        super.init(json: json)
        
        let dictionary = json.dictionaryValue
                
        for (categoryName, info) in dictionary {
            
            var dishes = [DiningItem]()
            
            if SPECIAL_NAMES.contains(categoryName) { continue }
            
            for (name, options) in JSON(parseJSON: info.stringValue).dictionaryValue {
                dishes.append(.init(name: name, category: categoryName, options: options))
            }
            
            if !dishes.isEmpty {
                menuItems[categoryName] = dishes
            }
        }
        
    }
    
    override var diningItems: [(name: String, items: [DiningItem])] {
        return menuItems.sorted { (pair1, pair2) -> Bool in
            return pair1.key < pair2.key
        }.map { (name: $0.key, items: $0.value) }
    }
    
}
