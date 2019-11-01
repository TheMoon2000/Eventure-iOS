//
//  SettingsItemCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/28.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SettingsItemCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var valueLabel: UILabel!
    private(set) var heightConstraint: NSLayoutConstraint!
    private(set) var spacingConstraint: NSLayoutConstraint!

    required init(withAccessory: Bool = true) {
        super.init(style: .default, reuseIdentifier: nil)
        
        //add arrow to each cell
        if withAccessory {
            accessoryType = .disclosureIndicator
        }
        
        backgroundColor = AppColors.background
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = AppColors.main
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 26).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        valueLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            addSubview(label)
            
            label.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.rightAnchor, constant: 16).isActive = true
            let constant: CGFloat = withAccessory ? -38 : -20
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: constant).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        } ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
