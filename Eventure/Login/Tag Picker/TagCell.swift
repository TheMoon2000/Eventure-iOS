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
            bg.backgroundColor = AppColors.main
            bg.layer.cornerRadius = 0
            bg.layer.borderWidth = 1.5
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                bg.layer.borderColor = UIColor(white: 0.1, alpha: 0.4).cgColor
            } else {
                bg.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            }
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
            label.lineBreakMode = .byCharWrapping
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 13
            label.textAlignment = .center
            label.textColor = .white
            label.numberOfLines = 3
            label.font = .appFontSemibold(16)
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
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    if self.isSelected {
                        self.bgTint.backgroundColor = AppColors.mainDark
                    } else {
                        self.bgTint.backgroundColor = AppColors.main
                    }
                },
                completion: nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            bgTint.layer.borderColor = UIColor(white: 0.1, alpha: 0.4).cgColor
        } else {
            bgTint.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
