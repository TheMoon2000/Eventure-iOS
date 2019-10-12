//
//  MajorPreviewCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MajorPreviewCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private var majorLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = AppColors.background
        
        icon = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "comments"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        majorLabel = {
            let label = UILabel()
            label.lineBreakMode = .byCharWrapping
            label.numberOfLines = 10
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
            
            return label
        }()
    }
    
    func setMajor(major: String) {
        if major == "Undeclared" {
            majorLabel.textColor = AppColors.prompt
        } else {
            majorLabel.textColor = AppColors.label
        }
        majorLabel.text = major
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
