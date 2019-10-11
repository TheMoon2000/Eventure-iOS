//
//  EmailProfileCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/5.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EmailProfileCell: UITableViewCell {

    private var parentVC: EditableInfoProvider!
    
    var icon: UIImageView!
    var linkButton: UIButton!
    var emailLabel: UILabel!
    
    required init(parentVC: EditableInfoProvider) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.parentVC = parentVC
        
        self.selectionStyle = .none
        backgroundColor = AppColors.background
        
        let h = heightAnchor.constraint(equalToConstant: 55)
        h.priority = .defaultHigh
        h.isActive = true
        
        icon = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "email"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        linkButton = {
            let button = UIButton(type: .system)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "mail").withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = AppColors.main
            button.imageEdgeInsets.left = 8
            button.imageEdgeInsets.right = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
            
            return button
        }()
        
        emailLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: linkButton.leftAnchor, constant: -5).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    
    @objc private func openLink() {
        if let url = URL(string: "mailto:" + emailLabel.text!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
