//
//  DatePickerBottomCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DatePickerBottomCell: UITableViewCell {

    private(set) var topCell: DatePickerTopCell!
    
    private(set) var timeLocationPage: DraftTimeLocationPage!
    
    var bgView: UIView!
    var datePicker: UIDatePicker!
    
    required init(timeLocationPage: DraftTimeLocationPage, topCell: DatePickerTopCell) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.topCell = topCell
        self.timeLocationPage = timeLocationPage
        
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
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
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
        topCell.displayedDate = datePicker.date
        if timeLocationPage.contentCells[1] == self {
            if let end = timeLocationPage.contentCells[3] as? DatePickerBottomCell {
                end.datePicker.minimumDate = datePicker.date.addingTimeInterval(5 * 60)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
