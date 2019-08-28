//
//  OrganizationCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class OrganizationCell: UITableViewCell {
        
    var logoImage: UIImageView!
    var orgTitle: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        logoImage = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: logoImage.rightAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }

    func setup(with org: OrganizationsViewController.OrgOverview) {
        
        orgTitle.text = org.title
        logoImage.image = org.logoImage
        
        if org.logoImage == nil {
            org.getLogoImage { orgWithLogo in
                self.setup(with: orgWithLogo)
            }
            // Set logo to default placeholder
            logoImage.backgroundColor = LINE_TINT
        } else {
            logoImage.backgroundColor = .clear
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
