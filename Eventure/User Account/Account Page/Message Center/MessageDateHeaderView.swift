//
//  MessageDateHeaderView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageDateHeaderView: UIView {
    
    private var bgView: UIView!
    private(set) var headerTitle: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        bgView = {
            let v = UIView()
            v.backgroundColor = AppColors.messageHeader
            v.layer.cornerRadius = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            v.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            v.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return v
        }()
        
        headerTitle = {
            let label = UILabel()
            label.text = "Replace me with a date"
            label.numberOfLines = 5
            label.font = .appFontRegular(13)
            label.textAlignment = .center
            label.textColor = UIColor(named: "AppColors.lightText")!
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 5).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -5).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 2).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -2).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
