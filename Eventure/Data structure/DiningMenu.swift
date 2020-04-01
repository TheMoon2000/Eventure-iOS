//
//  DiningMenu.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/25.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class DiningMenu {
    let location: String
    let isOpen: Bool
    let day: Int
    let message: String?
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
        return []
    }
}

class BreakfastMenu: DiningMenu {
    
    var breakfast: [DiningItem]?
    var hotGrains: [DiningItem]?
    var muffin: [DiningItem]?
    var danish: [DiningItem]?
    var byoBar: [DiningItem]?
    override var mealTime: Int { 0 }
    
    override init(json: JSON) {
        
        let dict = json.dictionaryValue
                        
        if let stringData = dict["ENTREES"]?.string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .breakfast, options: options))
            }
            breakfast = tmp
        }
        
        if let stringData = dict["HOT GRAINS"]?.string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .hotGrains, options: options))
            }
            hotGrains = tmp
        }
        
        if let stringData = dict["MUFFIN"]?.string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .muffin, options: options))
            }
            muffin = tmp
        }
        
        if let stringData = dict["DANISH"]?.string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .danish, options: options))
            }
            danish = tmp
        }
        
        if let stringData = dict["BYO BAR"]?.string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .byoBar, options: options))
            }
            byoBar = tmp
        }
        
        super.init(json: json)
    }

    override var diningItems: [(name: String, items: [DiningItem])] {
        return [breakfast, hotGrains, muffin, danish, byoBar]
            .filter { $0 != nil && $0!.count > 0 }
            .map { ($0![0].category.rawValue, $0!) }
    }
    
}

class LunchDiningMenu: DiningMenu {
    
    var brunch: [DiningItem]?
    var entrees: [DiningItem]?
    var bearFit: [DiningItem]?
    var grilled: [DiningItem]?
    var pizza: [DiningItem]?
    var pastas: [DiningItem]?
    var desserts: [DiningItem]?
    var soups: [DiningItem]?
    var deliSalad: [DiningItem]?
    var hotGrains: [DiningItem]?
    var muffin: [DiningItem]?
    var fusion: [DiningItem]?
    var centerOfThePlate: [DiningItem]?
    var specialtySalads: [DiningItem]?
    var kosherDeli: [DiningItem]?
    var danish: [DiningItem]?
    
    override var mealTime: Int { 1 }
    
    override init(json: JSON) {
        
        if let stringData = json["BREAKFAST"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .breakfast, options: options))
            }
            brunch = tmp
        }
        
        if let stringData = json["ENTREES"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .entrees, options: options))
            }
            entrees = tmp
        }
        
        if let stringData = json["BEAR FIT"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .bearFit, options: options))
            }
            bearFit = tmp
        }
        
        if let stringData = json["GRILLED"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .grilled, options: options))
            }
            grilled = tmp
        }
        
        if let stringData = json["PIZZAS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .pizza, options: options))
            }
            pizza = tmp
        }
        
        if let stringData = json["PASTAS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .pastas, options: options))
            }
            pastas = tmp
        }
        
        if let stringData = json["DESSERTS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .dessert, options: options))
            }
            desserts = tmp
        }
        
        if let stringData = json["SOUPS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .soups, options: options))
            }
            soups = tmp
        }
        
        if let stringData = json["DELI AND SALAD BAR"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .deliSalad, options: options))
            }
            deliSalad = tmp
        }
        
        if let stringData = json["HOT GRAINS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .hotGrains, options: options))
            }
            hotGrains = tmp
        }
        
        if let stringData = json["MUFFIN"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .muffin, options: options))
            }
            muffin = tmp
        }
        
        if let stringData = json["FUSION"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .bearFit, options: options))
            }
            bearFit = tmp
        }
        
        if let stringData = json["CENTER OF THE PLATE"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .centerOfThePlate, options: options))
            }
            centerOfThePlate = tmp
        }
        
        if let stringData = json["SPECIALTY SALADS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .specialtySalads, options: options))
            }
            specialtySalads = tmp
        }
        
        if let stringData = json["KOSHER DELI"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .kosherDeli, options: options))
            }
            kosherDeli = tmp
        }
        
        if let stringData = json["DANISH"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .danish, options: options))
            }
            danish = tmp
        }

        super.init(json: json)
    }
    
    override var diningItems: [(name: String, items: [DiningItem])] {
        return [
            brunch, entrees, bearFit, grilled, pizza, pastas, desserts, soups, deliSalad, hotGrains, muffin, fusion, centerOfThePlate, specialtySalads, kosherDeli, danish
        ]
            .filter { $0 != nil && $0!.count > 0 }
            .map { ($0![0].category.rawValue, $0!) }
    }
}

class DinnerDiningMenu: DiningMenu {
    
    var soups: [DiningItem]?
    var deliSalad: [DiningItem]?
    var entrees: [DiningItem]?
    var bearFit: [DiningItem]?
    var grilled: [DiningItem]?
    var pizza: [DiningItem]?
    var pastas: [DiningItem]?
    var desserts: [DiningItem]?
    var fusion: [DiningItem]?
    var centerOfThePlate: [DiningItem]?
    var specialtySalads: [DiningItem]?
    var kosherEntrees: [DiningItem]?
    var kosherDeli: [DiningItem]?
    
    override var mealTime: Int { 2 }
    
    override init(json: JSON) {
        
        if let stringData = json["SOUPS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .soups, options: options))
            }
            soups = tmp
        }
        
        if let stringData = json["DELI AND SALAD BAR"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .deliSalad, options: options))
            }
            deliSalad = tmp
        }
        
        if let stringData = json["ENTREES"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .entrees, options: options))
            }
            entrees = tmp
        }
        
        if let stringData = json["BEAR FIT"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .bearFit, options: options))
            }
            bearFit = tmp
        }
        
        if let stringData = json["GRILLED"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .grilled, options: options))
            }
            grilled = tmp
        }
        
        if let stringData = json["PIZZAS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .pizza, options: options))
            }
            pizza = tmp
        }
        
        if let stringData = json["PASTAS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .pastas, options: options))
            }
            pastas = tmp
        }
        
        if let stringData = json["DESSERTS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .dessert, options: options))
            }
            desserts = tmp
        }
        
        if let stringData = json["FUSION"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .fusion, options: options))
            }
            fusion = tmp
        }
        
        if let stringData = json["CENTER OF THE PLATE"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .centerOfThePlate, options: options))
            }
            centerOfThePlate = tmp
        }
        
        if let stringData = json["SPECIALTY SALADS"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .specialtySalads, options: options))
            }
            specialtySalads = tmp
        }
        
        if let stringData = json["KOSHER ENTREES"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .kosherEntrees, options: options))
            }
            kosherEntrees = tmp
        }
        
        if let stringData = json["KOSHER DELI"].string, let array = JSON(parseJSON: stringData).dictionary {
            var tmp = [DiningItem]()
            for (name, options) in array {
                tmp.append(DiningItem(name: name, category: .kosherDeli, options: options))
            }
            kosherDeli = tmp
        }
        
        super.init(json: json)
    }
    
    override var diningItems: [(name: String, items: [DiningItem])] {
        return [
            soups, deliSalad, entrees, bearFit, grilled, pizza, pastas, desserts, fusion, centerOfThePlate, specialtySalads, kosherEntrees, kosherDeli
        ]
            .filter { $0 != nil && $0!.count > 0 }
            .map { ($0![0].category.rawValue, $0!) }
    }
    
}
