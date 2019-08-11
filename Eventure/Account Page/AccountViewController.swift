//
//  AccountViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    var signOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Me"
        setUpButtons()
        
    }
    private func setUpButtons() {
        
        signOut = {
            let button = UIButton(type: .system)
            button.setTitle("Sign In", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17.2, weight: .semibold)
            button.tintColor = .black
            button.backgroundColor = .init(white: 1, alpha: 0.05)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1.0
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            button.heightAnchor.constraint(equalToConstant: 100).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            // Actions
            button.addTarget(self,
                             action: #selector(signOutNow),
                             for: .touchUpInside)
            return button
        }()
    }
    @objc private func signOutNow(_ sender: UIButton) {
        
        //should I present to navBar? What's the consequence of mixing modal and navigation?
        
        if sender.title(for: .normal) == "Sign In" {
            let login = LoginViewController()
            let nvc = InteractivePopNavigationController(rootViewController: login)
            nvc.isNavigationBarHidden = true
            login.navBar = nvc
            present(nvc, animated: true, completion: nil)
        } else {
            sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
            sender.backgroundColor = UIColor(white: 1, alpha: 0.15)
            UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
            
            MainTabBarController.current.openScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) == nil {
            signOut.setTitle("Sign In", for: .normal)
        } else {
            signOut.setTitle("Sign Out", for: .normal)
        }
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
