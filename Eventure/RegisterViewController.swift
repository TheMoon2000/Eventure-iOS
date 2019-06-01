//
//  RegisterViewController.swift
//  Eventure
//
//  Created by Xiang Li on 5/31/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        let g = UISwipeGestureRecognizer(target: self, action: #selector(returnToLogin))
        g.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(g)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view.
    }
    
    @objc private func returnToLogin() {
        //TODO: Use navigation controller for better animation
        self.navigationController?.popViewController(animated: true)
    }
}

