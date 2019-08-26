//
//  DatePickerBottomCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DatePickerBottomCell: UITableViewCell {
    
    private(set) var timeLocationPage: DraftTimeLocationPage!
    
    var bgView: UIView!
    var datePicker: UIDatePicker!
    
    var dateChangedHandler: ((Date) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2).isActive = true
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        
        datePicker = {
            let picker = UIDatePicker()
            picker.alpha = 0.0
            picker.isUserInteractionEnabled = false
            picker.minuteInterval = 5
            picker.locale = Locale(identifier: "en_US")
            picker.translatesAutoresizingMaskIntoConstraints = false
            addSubview(picker)
            
            picker.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
            picker.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            picker.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            picker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
            
            return picker
        }()
    }
    
    @objc private func valueChanged() {
        dateChangedHandler?(datePicker.date)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
