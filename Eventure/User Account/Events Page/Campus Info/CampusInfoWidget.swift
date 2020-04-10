//
//  CampusInfoWidget.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/28.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class CampusInfoWidget: UICollectionViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var name: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
                        
        icon = {
            let icon = UIImageView()
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.widthAnchor.constraint(equalToConstant: 65).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 65).isActive = true
            icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            
            return icon
        }()
        
        name = {
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 4
            label.font = .appFontRegular(14)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 8).isActive = true
            let b = label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
            b.priority = .defaultHigh
            b.isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
