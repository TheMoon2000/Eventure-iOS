//
//  DraftCapacityCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftCapacityCell: UITableViewCell, UITextFieldDelegate {

    private var bgView: UIView!
    private var leftLabel: UILabel!
    private(set) var valueField: UITextField!
    
    var changeHandler: ((UITextField) -> ())?
    var returnHandler: ((UITextField) -> ())?
    
    required init(title: String) {
        super.init(style: .default, reuseIdentifier: nil)
        
        backgroundColor = EventDraft.backgroundColor
        selectionStyle = .none
        
        let h = heightAnchor.constraint(equalToConstant: 66)
        h.priority = .defaultHigh
        h.isActive = true
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        leftLabel = {
            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        valueField = {
            let textfield = UITextField()
            textfield.textAlignment = .right
            textfield.keyboardType = .numberPad
            textfield.placeholder = "0"
            textfield.delegate = self
            textfield.returnKeyType = .done
            textfield.font = .systemFont(ofSize: 17)
            textfield.translatesAutoresizingMaskIntoConstraints = false
            addSubview(textfield)
            
            textfield.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: 10).isActive = true
            textfield.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            textfield.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            textfield.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
            
            return textfield
        }()
    }

    @objc private func valueChanged() {
        changeHandler?(valueField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        returnHandler?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
