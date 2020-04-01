//
//  DiningHallMessageCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/30.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class DiningHallMessageCell: UITableViewCell {

    private var bar: UIView!
    private(set) var message: UITextView!
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        backgroundColor = .clear
        
        bar = {
            let bar = UIView()
            bar.backgroundColor = AppColors.announcementDark
            bar.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bar)
            
            bar.widthAnchor.constraint(equalToConstant: 4).isActive = true
            bar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            
            return bar
        }()
        
        message = {
            let tv = UITextView()
            tv.backgroundColor = AppColors.announcement
            tv.font = .appFontRegular(16)
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.textContainerInset = .init(top: 12, left: 11, bottom: 12, right: 12)
            tv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: bar.rightAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            tv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            tv.heightAnchor.constraint(equalTo: bar.heightAnchor).isActive = true
            tv.centerYAnchor.constraint(equalTo: bar.centerYAnchor).isActive = true
            
            return tv
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
