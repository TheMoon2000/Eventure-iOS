//
//  DiningIconDefinitionCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/1.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class DiningIconDefinitionCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var title: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        icon = {
            let icon = UIImageView()
            icon.tintColor = AppColors.label
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 50).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 25).isActive = true
            
            return icon
        }()
        
        title = {
            let label = UILabel()
            label.numberOfLines = 2
            label.textColor = AppColors.label
            label.font = .appFontRegular(18)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -50).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
