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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = MAIN_DISABLED
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.layer.masksToBounds = true
            iv.layer.cornerRadius = 10
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 60).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 15).isActive = true
            iv.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15).isActive = true
            
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            label.textColor = UIColor.gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            label.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
            
            return label
        } ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
