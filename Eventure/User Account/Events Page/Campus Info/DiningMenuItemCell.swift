//
//  DiningMenuItemCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/31.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import BonMot

class DiningMenuItemCell: UITableViewCell {
    
    private var title: UILabel!

    required init(_ diningItem: DiningItem) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = AppColors.background
        
        title = {
            let label = UILabel()
            label.font = .appFontRegular(16)
            label.textColor = AppColors.label
            label.numberOfLines = 10
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
            
            return label
        }()
        
        let itemString = NSMutableAttributedString(string: diningItem.itemName + "  ")
        
        let orderedOptions = DiningItem.strToRawValue
            .sorted { $0.value < $1.value }
            .map { (name: $0.key, option: DiningItem.Options(rawValue: $0.value)) }
                
        for i in 0..<orderedOptions.count {
            if diningItem.options.contains(orderedOptions[i].option) {
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
                        
        title.attributedText = itemString.styled(with: .lineHeightMultiple(1.15))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
