//
//  ApplicationDateCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/12/14.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ApplicationDateCell: UITableViewCell {
    
    private(set) var picker: UIDatePicker!
    
    var dateChangedHandler: ((Date) -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = AppColors.background
        
        picker = {
            let picker = UIDatePicker()
            picker.alpha = 0
            picker.isUserInteractionEnabled = false
            picker.minuteInterval = 5
            picker.translatesAutoresizingMaskIntoConstraints = false
            addSubview(picker)
            
            picker.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            picker.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            picker.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            picker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
            
            return picker
        }()
    }
    
    @objc private func valueChanged() {
        dateChangedHandler?(picker.date)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
