//
//  CategoryCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/15.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    private var bgView: UIView!
    private var categoryBG: UIImageView!
    private(set) var categoryLabel: UILabel!
    var initTime: Date!
    
    var logoImage: UIImage? = nil {
        didSet {
            UIView.transition(with: categoryBG, duration: 0.2, options: .curveEaseInOut, animations: {
                self.categoryBG.image = self.logoImage
                self.categoryBG.alpha = self.logoImage == nil ? 0.0 : 0.5
                self.bgView.backgroundColor = self.logoImage == nil ? .gray : AppColors.categoryBG
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        initTime = Date()
        
        backgroundColor = .clear
        
        bgView = {
            let v = UIView()
            v.layer.cornerRadius = 5
            v.clipsToBounds = true
            v.backgroundColor = .gray
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            return v
        }()
        
        categoryBG = {
            let bg = UIImageView()
            bg.contentMode = .scaleAspectFill
            bg.clipsToBounds = true
            bg.alpha = 0.0
            bg.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(bg)
            
            bg.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            bg.topAnchor.constraint(equalTo: bgView.topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
            
            return bg
        }()
        
        categoryLabel = {
            let label = UILabel()
            label.text = "Category Name"
            label.font = .appFontSemibold(19)
            label.textAlignment = .center
            label.numberOfLines = 5
            label.textColor = .init(white: 0.99, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            let l = label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10)
            l.priority = .defaultHigh
            l.isActive = true
            
            let r = label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10)
            r.priority = .defaultHigh
            r.isActive = true
            
            return label
        }()
        
    }
    
    func updateLogo(tag: Tag) {
        
        let currentInitTime = initTime
        
        if tag.hasLogo != false {
            tag.getLogo { possibleImage in
                
                if self.initTime! > currentInitTime! { return }
                
                if possibleImage != nil {
                    self.logoImage = possibleImage
                } else {
                    self.logoImage = #imageLiteral(resourceName: "default_category_BG")
                }
            }
        } else if tag.hasLogo == false {
            self.logoImage = #imageLiteral(resourceName: "default_category_BG")
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
