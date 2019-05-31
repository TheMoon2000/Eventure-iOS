//
//  LoginViewController.swift
//  Eventure
//
//  Created by Xiang Li on 5/29/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var usr = UITextField()
    var pswd = UITextField()
    var logOrReg = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MAIN_TINT
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.setupLogins()
    }
    
    private func setupLogins() {
        usr.placeholder = "email"
        usr.borderStyle = .roundedRect
        usr.keyboardType = UIKeyboardType.default
    
        pswd.placeholder = "password"
        pswd.borderStyle = .roundedRect
        pswd.keyboardType = UIKeyboardType.default
        
        logOrReg.setTitle("Log In / Join", for: .normal)
        logOrReg.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        logOrReg.tintColor = .white
        logOrReg.backgroundColor = MAIN_TINT_DARK
        logOrReg.layer.cornerRadius = 18
        
        view.addSubview(usr)
        view.addSubview(pswd)
        view.addSubview(logOrReg)
        
        pswd.translatesAutoresizingMaskIntoConstraints = false
        usr.translatesAutoresizingMaskIntoConstraints = false
        logOrReg.translatesAutoresizingMaskIntoConstraints = false
        
        //Let pswd be the center anchor
        pswd.widthAnchor.constraint(equalToConstant: 210).isActive = true
        pswd.heightAnchor.constraint(equalToConstant: 45).isActive = true
        pswd.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pswd.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        usr.widthAnchor.constraint(equalToConstant: 210).isActive = true
        usr.heightAnchor.constraint(equalToConstant: 45).isActive = true
        usr.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usr.centerYAnchor.constraint(equalTo: pswd.centerYAnchor, constant: -50).isActive = true
        
        logOrReg.widthAnchor.constraint(equalToConstant: 186).isActive = true
        logOrReg.heightAnchor.constraint(equalToConstant: 48).isActive = true
        logOrReg.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logOrReg.centerYAnchor.constraint(equalTo: pswd.centerYAnchor, constant: 65).isActive = true
        //login/register transition page
        logOrReg.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    @objc private func buttonPressed() {
        //TODO: NEED API here
        //print(sender.text)
        let nextVC = MainTabBarController()
        //nextVC.modalTransitionStyle = .coverVertical
        self.present(nextVC, animated: true, completion: nil)
    }
    @objc private func dismissKeyboard() {
        if (usr.isEditing) {
            print("usr")
            usr.resignFirstResponder()
        } else if (pswd.isEditing) {
            print("pswd")
            pswd.resignFirstResponder()
        }
    }
    
}
