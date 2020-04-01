//
//  DiningItem.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/27.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class DiningItem: CustomStringConvertible {
    let itemName: String
    let category: Category
    let options: Options
    
    lazy var attributedString: NSAttributedString = {
        let itemString = NSMutableAttributedString(string: self.itemName + "  ")
        
        let orderedOptions = DiningItem.strToRawValue
            .sorted { $0.value < $1.value }
            .map { (name: $0.key, option: DiningItem.Options(rawValue: $0.value)) }
                
        for i in 0..<orderedOptions.count {
            if options.contains(orderedOptions[i].option) {
                if let image = UIImage(named: orderedOptions[i].name) {
                    let formattedImage = i >= 9 ? image.tintedImage(color: AppColors.label) : image
                    let offset: CGFloat = i >= 9 ? -4.0 : -3.0
                    itemString.append(NSAttributedString.composed(of: [
                        formattedImage.styled(with: .baselineOffset(offset))
                    ]))
                } else {
                    print("WARNING: image for \(orderedOptions[i].name) not found!")
                }
            }
        }
                        
        return itemString.styled(with: .lineHeightMultiple(1.15))
    }()
    
    static let strToRawValue: [String: Int] = [
        "Milk":              1,
        "Egg":               1 << 1,
        "Shellfish":         1 << 2,
        "Fish":              1 << 3,
        "Tree Nuts":         1 << 4,
        "Wheat":             1 << 5,
        "Peanuts":           1 << 6,
        "Sesame":            1 << 7,
        "Soybeans":          1 << 8,
        "Vegan Option":      1 << 9,
        "Vegetarian Option": 1 << 10,
        "Contains Gluten":   1 << 11,
        "Contains Pork":     1 << 12,
        "Contains Alcohol":  1 << 13,
        "Halal":             1 << 14,
        "Kosher":            1 << 15
    ]
    
    /// Create a new dining item based on the provided information.
    init(name: String, category: Category, options: JSON) {
        self.itemName = name
        self.category = category
        
        var tmp = Options()
        if let optionArray = options.arrayObject as? [String] {
            for i in optionArray {
                if let option = DiningItem.Options(name: i) {
                    tmp.insert(option)
                }
            }
        }
        
        self.options = tmp
    }
    
    var description: String {
        return "DiningItem(name: '\(itemName)')"
    }
}

extension DiningItem {
    
    struct Options: OptionSet {
        let rawValue: Int
        
        static let milk             = Options(rawValue: 1)
        static let egg              = Options(rawValue: 1 << 1)
        static let shellfish        = Options(rawValue: 1 << 2)
        static let fish             = Options(rawValue: 1 << 3)
        static let treeNuts         = Options(rawValue: 1 << 4)
        static let wheat            = Options(rawValue: 1 << 5)
        static let peanuts          = Options(rawValue: 1 << 6)
        static let sesame           = Options(rawValue: 1 << 7)
        static let soybeans         = Options(rawValue: 1 << 8)
        static let vegan            = Options(rawValue: 1 << 9)
        static let vegetarian       = Options(rawValue: 1 << 10)
        static let gluten           = Options(rawValue: 1 << 11)
        static let pork             = Options(rawValue: 1 << 12)
        static let alcohol          = Options(rawValue: 1 << 13)
        static let halal            = Options(rawValue: 1 << 14)
        static let kosher           = Options(rawValue: 1 << 15)
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        init?(name: String) {
            if let raw = DiningItem.strToRawValue[name] {
                self.rawValue = raw
            } else {
                return nil
            }
        }
    }
    
    enum Category: String {
        case bearFit = "Bear Fit"
        case breakfast = "Breakfast"
        case brunch = "Brunch"
        case byoBar = "BYO Bar"
        case centerOfThePlate = "Center of the Plate"
        case danish = "Danish"
        case deliSalad = "Deli Salad"
        case dessert = "Dessert"
        case entrees = "Entrees"
        case fusion = "Fusion"
        case grilled = "Grilled"
        case hotGrains = "Hot Grains"
        case kosherDeli = "Kosher Deli"
        case kosherEntrees = "Kosher Entrees"
        case muffin = "Muffin"
        case pastas = "Pastas"
        case pizza = "Pizza"
        case soups = "Soups"
        case specialtySalads = "Specialty Salads"
    }
}
