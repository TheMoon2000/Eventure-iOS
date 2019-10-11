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
            label.lineBreakMode = .byCharWrapping
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 13
            label.textAlignment = .center
            label.textColor = .white
            label.numberOfLines = 3
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
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    if self.isSelected {
                        self.bgTint.backgroundColor = MAIN_TINT_DARK
                    } else {
                        self.bgTint.backgroundColor = AppColors.main
                    }
                },
                completion: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
