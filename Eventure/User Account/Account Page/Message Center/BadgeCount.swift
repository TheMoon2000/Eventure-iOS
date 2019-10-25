//
//  BadgeCount.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class BadgeCount: UIView {

    private var badgeBG: UIView!
    private var badgeLabel: UILabel!
    
    var badgeNumber: Int = 0 {
        didSet {
            badgeLabel.text = badgeNumber < 100 ? String(badgeNumber) : "99+"
            isHidden = badgeNumber == 0
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        isHidden = true
        
        badgeBG = {
            let bg = UIView()
            bg.backgroundColor = AppColors.badgeColor
            bg.layer.cornerRadius = 9
            bg.layer.masksToBounds = true
            bg.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bg)
            
            bg.heightAnchor.constraint(equalToConstant: 18).isActive = true
            bg.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            bg.topAnchor.constraint(equalTo: topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            let w = bg.widthAnchor.constraint(equalTo: bg.heightAnchor)
            w.priority = .defaultLow
            w.isActive = true

            return bg
        }()
        
        badgeLabel = {
            let label = UILabel()
            label.text = "0"
            label.font = .systemFont(ofSize: 12)
            label.textColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(greaterThanOrEqualTo: badgeBG.leftAnchor, constant: 5).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badgeBG.rightAnchor, constant: -5).isActive = true
            
            label.centerXAnchor.constraint(equalTo: badgeBG.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: badgeBG.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
