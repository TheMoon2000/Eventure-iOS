//
//  ProfilePreviewCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ProfilePreviewCell: UITableViewCell {

    private(set) var icon: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private var stack: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppColors.background
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = AppColors.mainDisabled
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 15).isActive = true
            let b = iv.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15)
            b.priority = .defaultHigh
            b.isActive = true
            
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false

            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        stack = {
            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 5
            stack.alignment = .leading
            stack.distribution = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stack)
            
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 15).isActive = true
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15).isActive = true
            stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            stack.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 18).isActive = true
            stack.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return stack
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
