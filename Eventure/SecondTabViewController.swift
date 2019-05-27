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
        button.setTitle("Get Current IP", for: .normal)
        button.layer.borderColor = MAIN_TINT.cgColor
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 24
        button.tintColor = MAIN_TINT
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 186).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    /// Remove this!
    
    @objc private func buttonPressed() {
        // Get the IP of the user
        
        let apiURL = URL(string: API_BASE_URL + "/network/GetIP")!
        
        
        // Setup alert view controller
        let alert = UIAlertController(title: "IP Address Lookup",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .default,
                                      handler: nil))
        
        let task = CUSTOM_SESSION.dataTask(with: apiURL) {
            data, response, error in
            
            guard error == nil else {
                print(error!)
                alert.message = "Connection error."
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let ip = String(data: data!, encoding: .utf8) {
                alert.message = "Your IP is \(ip)."
            } else {
                alert.message = "Unable to retrieve IP."
            }
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        task.resume()
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
