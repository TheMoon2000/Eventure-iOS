//
//  AccountCell.swift
//  Eventure
//
//  Created by jeffhe on 2019/8/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//


import UIKit

class AccountCell: UITableViewCell {
    
    var functionImage: UIImageView!
    var function: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        functionImage = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        function = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: functionImage.rightAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }
    
    func setup(rowNum: Int) {
        functionImage.image = UIImage(named: "done")
        function.text = String(rowNum)
        /*
        logoImage.image = org.logoImage
        if logoImage.image != nil {
            logoImage.backgroundColor = .clear
        } else {
            logoImage.backgroundColor = LINE_TINT
        }*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

