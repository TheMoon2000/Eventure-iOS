//
//  OrganizationSettingCell.swift
//  Eventure
//
//  Created by Prince Wang on 2019/8/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import QuartzCore

class OrganizationSettingCell: UITableViewCell {
    
    var functionImage: UIImageView!
    var function: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        functionImage = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            //Image constraints
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
            
            
            //label constraints
            label.leftAnchor.constraint(equalTo: functionImage.rightAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }
    
    func setup(sectionNum: Int, rowNum: Int) {
        if (sectionNum == 0 && rowNum == 0) {
            functionImage = {
                let iv = UIImageView()
                iv.translatesAutoresizingMaskIntoConstraints = false
                iv.layer.cornerRadius = 20
                iv.clipsToBounds = true
                addSubview(iv)
                
                iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
                iv.widthAnchor.constraint(equalToConstant: 80).isActive = true
                iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
                iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                return iv
            }()
            functionImage.image = UIImage(named: "oski")
            function.text = ""
        } else if (sectionNum == 1){
            if (rowNum == 0){
                functionImage.image = UIImage(named: "name")
                function.text = "Organization Name"
            } else if (rowNum == 1) {
                functionImage.image = UIImage(named: "password")
                function.text = "Password"
            } else if (rowNum == 2) {
                functionImage.image = UIImage(named: "tag")
                function.text = "Tags"
            } else if (rowNum == 3) {
                functionImage.image = UIImage(named: "description")
                function.text = "Description"
            } else {
                
            }
        } else if (sectionNum == 2){
            if (rowNum == 0){
                functionImage.image = UIImage(named: "email")
                function.text = "Email"
            } else if (rowNum == 1) {
                functionImage.image = UIImage(named: "phone")
                function.text = "Phone"
            } else if (rowNum == 2) {
                functionImage.image = UIImage(named: "website")
                function.text = "Website"
            }
            else {
                
            }
        } else if (sectionNum == 3){
            if (rowNum == 0){
                functionImage.image = UIImage(named: "event")
                function.text = "Events"
            } else if (rowNum == 1) {
                functionImage.image = UIImage(named: "follower")
                function.text = "Subscription"
            }
            else {
                
            }
        } else if (sectionNum == 4) {
            functionImage.image = UIImage(named: "settings")
            if UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) == nil {
                function.text = "Sign In"
            } else {
                function.text = "Log Off"
            }
        }
        else {
            
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
