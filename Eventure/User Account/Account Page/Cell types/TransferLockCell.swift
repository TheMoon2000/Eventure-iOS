//
//  TransferLockCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TransferLockCell: UITableViewCell {
    
    private(set) var titleLabel: UILabel!
    private(set) var lockSwitch: UISwitch!
    
    var switchHandler: ((UISwitch) -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let h = heightAnchor.constraint(equalToConstant: 55)
        h.priority = .defaultHigh
        h.isActive = true
        
        
        titleLabel = {
            let label = UILabel()
            label.text = "Transfer lock"
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        lockSwitch = {
            let s = UISwitch()
            s.onTintColor = MAIN_TINT
            s.translatesAutoresizingMaskIntoConstraints = false
            addSubview(s)
            
            s.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            s.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            s.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
            
            return s
        }()
    }
    
    @objc private func switchTriggered() {
        UISelectionFeedbackGenerator().selectionChanged()
        switchHandler?(lockSwitch)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
