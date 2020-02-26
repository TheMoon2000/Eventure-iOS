//
//  SeparatorView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SeparatorCell: UITableViewCell {
    
    init(top: CGFloat, bottom: CGFloat) {
        super.init(style: .default, reuseIdentifier: nil)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        heightAnchor.constraint(equalToConstant: 1 + top + bottom).isActive = true
        
        let separator = UIView()
        separator.backgroundColor = AppColors.line
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 90).isActive = true
        separator.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottom).isActive = true
        separator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
