//
//  LoginViewController.swift
//  Eventure
//
//  Created by Xiang Li on 5/29/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MAIN_TINT
        self.setupLogins()
        // Do any additional setup after loading the view.
    }
    
    private func setupLogins() {
        let usr = UITextField()
        usr.placeholder = "email"
        usr.borderStyle = .roundedRect
        
        let pswd = UITextField()
        pswd.placeholder = "password"
        pswd.borderStyle = .roundedRect
        
        let logOrReg = UIButton(type: .system)
        logOrReg.setTitle("Log In / Join", for: .normal)
        logOrReg.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        logOrReg.tintColor = .white
        logOrReg.backgroundColor = UIColor(red: 0/255, green: 219/255, blue: 182/255, alpha: 1)
        logOrReg.layer.cornerRadius = 18
        
        view.addSubview(usr)
        view.addSubview(pswd)
        view.addSubview(logOrReg)
        
        pswd.translatesAutoresizingMaskIntoConstraints = false
        usr.translatesAutoresizingMaskIntoConstraints = false
        logOrReg.translatesAutoresizingMaskIntoConstraints = false
        
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
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
