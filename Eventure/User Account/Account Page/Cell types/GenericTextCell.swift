//
//  GenericTextCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class GenericTextCell: UITableViewCell, UITextFieldDelegate {
    
    private(set) var inputField: UITextField!
    private(set) var spinner: UIActivityIndicatorView!
    
    /// The handler to run when the new input is submitted.
    var submitAction: ((UITextField, UIActivityIndicatorView) -> ())?
    
    /// On text change.
    var changeHandler: ((UITextField) -> ())?
    
    /// On text end editing.
    var endEditingHandler: ((UITextField) -> ())?

    
    required init(title: String) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = AppColors.background
        
        let h = heightAnchor.constraint(equalToConstant: 50)
        h.priority = .defaultHigh
        h.isActive = true
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.color = AppColors.lightControl
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            addSubview(spinner)
            
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            spinner.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return spinner
        }()
        
        inputField = {
            let field = UITextField()
            field.placeholder = title
            field.clearButtonMode = .whileEditing
            field.returnKeyType = .done
            field.textColor = AppColors.value
            field.delegate = self
            field.font = .appFontRegular(17)
            field.enablesReturnKeyAutomatically = true
            field.translatesAutoresizingMaskIntoConstraints = false
            addSubview(field)
            
            field.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            field.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -18).isActive = true
            field.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            field.heightAnchor.constraint(equalTo: heightAnchor, constant: -5).isActive = true
            
            field.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
            
            return field
        }()
    }
    
    func submit() {
        submitAction?(inputField, spinner)
    }
    
    @objc func textfieldDidChange() {
        changeHandler?(inputField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingHandler?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
