//
//  MajorCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MajorCell: UITableViewCell {

    var isChecked = false {
        didSet {
            accessoryType = isChecked ? .checkmark : .none
        }
    }
    
    private(set) var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppColors.background
        
        titleLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.numberOfLines = 10
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
