//
//  TagCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/7/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    var tagLabel: UILabel!
    private var bgTint: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        bgTint = {
            let bg = UIView()
            bg.backgroundColor = MAIN_TINT
            bg.layer.cornerRadius = 0
            bg.layer.borderWidth = 1.5
            bg.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            bg.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bg)
            
            bg.topAnchor.constraint(equalTo: topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            return bg
        }()
        
        tagLabel = {
            let label = UILabel()
            label.lineBreakMode = .byWordWrapping
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.textColor = .white
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            
            return label
        }()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bgTint.backgroundColor = MAIN_TINT_DARK
            } else {
                bgTint.backgroundColor = MAIN_TINT
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
