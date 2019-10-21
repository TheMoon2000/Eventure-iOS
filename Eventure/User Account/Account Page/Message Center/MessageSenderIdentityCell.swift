//
//  MessageSenderIdentityCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageSenderIdentityCell: UITableViewCell {

    private(set) var senderLogo: UIImageView!
    private(set) var contactName: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppColors.background
        
        let h = heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        h.priority = .defaultHigh
        h.isActive = true
        
        senderLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 40).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        contactName = {
            let label = UILabel()
            label.numberOfLines = 5
            label.font = .systemFont(ofSize: 17.5)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: senderLogo.rightAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }
    
    func setup(sender: AccountNotification.Sender) {
        contactName.text = sender.name
        if let logo = AccountNotification.current[sender]?.last?.senderLogo {
            senderLogo.image = logo
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
