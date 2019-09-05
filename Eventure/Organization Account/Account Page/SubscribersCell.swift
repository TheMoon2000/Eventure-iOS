//
//  SubscribersCell.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit

class SubscribersCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var imageWidthConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!
    private(set) var spacingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //FIXME: Change constraints
        icon = {
            let iv = UIImageView()
            iv.tintColor = MAIN_TINT
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            imageWidthConstraint = iv.widthAnchor.constraint(equalToConstant: 60)
            imageWidthConstraint.isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        
        //FIXME: Change constraints
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 10
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.lineBreakMode = .byWordWrapping
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -32).isActive = true
            
            return label
        }()
    
}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    

}
