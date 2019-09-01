//
//  GraduationYearChooser.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class GraduationYearChooser: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var picker: UIPickerView!
    var selectionHandler: ((Int, User.GraduationSeason) -> ())?
    
    private var yearList: [Int] {
        let currentYear = Int(YEAR_FORMATTER.string(from: Date()))!
        let earliest = currentYear - 80
        let latest = currentYear + 20
        return Array(earliest...latest)
    }
    
    private var seasons: [User.GraduationSeason] = [.spring, .fall]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        picker = {
            let picker = UIPickerView()
            picker.alpha = 0
            picker.isUserInteractionEnabled = false
            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true
            picker.reloadAllComponents()
            picker.selectRow(82, inComponent: 0, animated: false) // This year
            picker.selectRow(0, inComponent: 1, animated: false) // Spring
            picker.translatesAutoresizingMaskIntoConstraints = false
            addSubview(picker)
            
            picker.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            picker.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            picker.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return picker
        }()
    }
    
    // MARK: - Picker view data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return [yearList.count, seasons.count][component]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(yearList[row])
        } else {
            return seasons[row].rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        valueChanged()
    }
    
    @objc func valueChanged() {
        let year = yearList[picker.selectedRow(inComponent: 0)]
        let season = seasons[picker.selectedRow(inComponent: 1)]
        
        selectionHandler?(year, season)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
