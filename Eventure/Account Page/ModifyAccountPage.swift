//
//  ModifyAccountPage.swift
//  Eventure
//
//  Created by jeffhe on 2019/8/24.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit

class ModifyAccountPage: UIViewController {
    
    private var myTextBox: UITextField!
    private var displayedName: String!
    
    init(name: String) {
        super.init(nibName: nil, bundle: nil)
        displayedName = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        
        myTextBox = {
            let myTextBox = UITextField()
            myTextBox.text = displayedName
            myTextBox.keyboardType = .emailAddress
            myTextBox.adjustsFontSizeToFitWidth = true
            myTextBox.textContentType = .emailAddress
            myTextBox.returnKeyType = .next
            prepareField(textfield: myTextBox)
            myTextBox.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(myTextBox)
            
            myTextBox.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            myTextBox.heightAnchor.constraint(equalToConstant: 45).isActive = true
            myTextBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            myTextBox.topAnchor.constraint(equalTo: view.centerYAnchor,
                                     constant: -320).isActive = true
            
            return myTextBox
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(changeName))
        
    }
    
    private func prepareField(textfield: UITextField) {
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.clearButtonMode = .whileEditing
        textfield.backgroundColor = .white
        textfield.borderStyle = .none
        textfield.layer.borderColor = UIColor(white: 0.5, alpha: 0.24).cgColor
        textfield.layer.borderWidth = 1.4
        textfield.layer.cornerRadius = 4
        textfield.doInset()
    }

    @objc private func changeName() {
        self.navigationController?.popViewController(animated: true)
    }
}
