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
        
        title.attributedText = diningItem.attributedString
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
