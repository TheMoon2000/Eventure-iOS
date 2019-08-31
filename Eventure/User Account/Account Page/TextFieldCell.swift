//
//  TextFieldCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    var icon: UIImageView!
    var textfield: UITextField!
    
    var endEditingHandler: ((UITextField) -> ())?
    var returnHandler: ((UITextField) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        let h = heightAnchor.constraint(equalToConstant: 55)
        h.priority = .defaultHigh
        h.isActive = true
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = MAIN_TINT
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        textfield = {
            let tf = UITextField()
            tf.delegate = self
            tf.adjustsFontSizeToFitWidth = true
            tf.clearButtonMode = .whileEditing
            tf.minimumFontSize = 10
            tf.returnKeyType = .done
            tf.autocorrectionType = .no
            tf.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tf)
            
            tf.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            tf.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            tf.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return tf
        }()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingHandler?(textfield)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnHandler?(textField)
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
