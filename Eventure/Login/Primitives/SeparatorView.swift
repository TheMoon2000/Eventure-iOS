//
//  SeparatorView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SeparatorView: UIView {

    init() {
        super.init(frame: .zero)
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let separator = UIView()
        separator.backgroundColor = LINE_TINT
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 90).isActive = true
        separator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        separator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
