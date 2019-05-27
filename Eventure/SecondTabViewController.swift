//
//  SecondTabViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SecondTabViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Second Tab"
        
        // remove this example UIButton
        self.makeButton()
    }
    
    /// Remove this!
    private func makeButton() {
        let button = UIButton(type: .system)
        button.setTitle("UIButton", for: .normal)
        button.layer.borderColor = MAIN_TINT.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 24
        button.tintColor = MAIN_TINT
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 184).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    /// Remove this!
    
    @objc private func buttonPressed() {
        print("Button pressed at \(Date())")
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
