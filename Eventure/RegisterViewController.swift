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
        self.view.backgroundColor = MAIN_TINT
        let g = UISwipeGestureRecognizer(target: self, action: #selector(returnToLogin))
        g.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(g)
        // Do any additional setup after loading the view.
    }
    

    @objc private func returnToLogin() {
        //TODO: Use navigation controller for better animation
        let nextVC = LoginViewController()
        nextVC.modalTransitionStyle = .flipHorizontal
        self.present(nextVC, animated: true, completion: nil)
    }
}
