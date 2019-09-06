//
//  AccountCell.swift
//  Eventure
//
//  Created by jeffhe on 2019/8/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//


import UIKit
import QuartzCore

class AccountCell: UITableViewCell {
    
    var functionImage: UIImageView!
    var function: UILabel!
    var sideLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //add arrow to each cell
        accessoryType = .disclosureIndicator
        
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
        
        sideLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.textColor = UIColor.gray
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo:function.rightAnchor, constant: 100).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor,constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        } ()
    }
   
    
    func setup(sectionNum: Int, rowNum: Int, type: String) {
        if type == "Account" {
            if (sectionNum == 1 && rowNum == 0) {
                functionImage.image = UIImage(named: "write")
                function.text = "Manage Account"
            } else if (sectionNum == 2 && rowNum == 0) {
                functionImage.image = UIImage(named: "heart")
                function.text = "Favorite Events"
            } else if (sectionNum == 2 && rowNum == 1) {
                functionImage.image = UIImage(named: "done")
                function.text = "Going"
            } else if (sectionNum == 2 && rowNum == 2) {
                functionImage.image = UIImage(named: "subscribe")
                function.text = "Subscriptions"
            } else if (sectionNum == 2 && rowNum == 3) {
                functionImage.image = UIImage(named: "tag")
                function.text = "My Tags"
            }else if (sectionNum == 3 && rowNum == 0) {
                functionImage.image = UIImage(named: "settings")
                if User.current == nil {
                    function.text = "Sign In"
                } else {
                    function.text = "Log Off"
                }
            } else {
                functionImage.image = UIImage(named: "done")
                function.text = String(rowNum)
            }
        } else {
            if rowNum == 0 {
                functionImage.image = UIImage(named: "name")
                sideLabel.text = User.current?.displayedName
                function.text = "Name"
            } else if rowNum == 1 {
                functionImage.image = UIImage(named: "password")
                function.text = "Password"
                sideLabel.text = "•••••••"
            } else if rowNum == 2 {
                functionImage.image = UIImage(named: "email")
                function.text = "Email"
            } else if rowNum == 3 {
                functionImage.image = UIImage(named: "gender")
                function.text = "Gender"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

