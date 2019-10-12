//
//  SettingsSwitchCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SettingsSwitchCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var titleLabel: UILabel!
    
    var switchHandler: ((Bool) -> ())?
    
    var enabled = true {
        didSet {
            switchItem.isOn = enabled
        }
    }
    private var switchItem: UISwitch!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            
            view.heightAnchor.constraint(equalToConstant: 55).isActive = true

            
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Ascending"
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            return label
        }()
        
        switchItem = {
            let s = UISwitch()
            s.onTintColor = AppColors.main
            s.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(s)
            
            s.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -12).isActive = true
            s.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            s.addTarget(self, action: #selector(changeValue), for: .valueChanged)
            
            return s
        }()
    }
    
    @objc private func changeValue() {
        UISelectionFeedbackGenerator().selectionChanged()
        switchHandler?(switchItem.isOn)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
