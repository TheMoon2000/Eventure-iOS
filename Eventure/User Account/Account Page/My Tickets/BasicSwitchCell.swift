//
//  BasicSwitchCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class BasicSwitchCell: UITableViewCell {
    
    private(set) var titleLabel: UILabel!
    private(set) var `switch`: UISwitch!
    
    var switchHandler: ((UISwitch) -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let h = heightAnchor.constraint(equalToConstant: 50)
        h.priority = .defaultHigh
        h.isActive = true
        
        
        titleLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        `switch` = {
            let s = UISwitch()
            s.onTintColor = AppColors.main
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
        switchHandler?(`switch`)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
