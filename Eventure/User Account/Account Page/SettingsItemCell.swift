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
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = MAIN_TINT
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        valueLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.textAlignment = .right
            label.textColor = UIColor.gray
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            addSubview(label)
            
            label.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.leftAnchor, constant: 20).isActive = true
            let constant: CGFloat = withAccessory ? -38 : -20
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: constant).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        } ()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
