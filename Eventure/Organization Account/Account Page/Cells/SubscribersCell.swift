//
//  SubscribersCell.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit

class SubscribersCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private var stack: UIStackView!
    private(set) var heightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppColors.background
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = AppColors.mainDisabled
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 42).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 15).isActive = true
            iv.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15).isActive = true
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .appFontMedium(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .appFontRegular(16)
            label.textColor = UIColor.gray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        stack = {
            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 5
            stack.alignment = .leading
            stack.distribution = .fillProportionally
            stack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stack)
            
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 12).isActive = true
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12).isActive = true
            stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            stack.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            stack.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return stack
        }()
}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
