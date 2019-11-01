//
//  UnsupportedContentCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// This cell acts as a fallback cell when displaying unsupported chat content.
class UnsupportedContentCell: UITableViewCell {

    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var contentText: UILabel!
    
    required init(content: AccountNotification) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let v = UIView()
            v.backgroundColor = AppColors.messageHeader
            v.layer.cornerRadius = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            v.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            v.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            return v
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.text = "Unsupported content type. Please update Eventure to view this message."
            label.numberOfLines = 5
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .center
            label.textColor = UIColor(named: "AppColors.lightText")!
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 4).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -4).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
