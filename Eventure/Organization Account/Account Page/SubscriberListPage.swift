//
//  subscriberListPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class SubscriberListPage: UIViewController {
    //define variables that stores all the subscribers of the club
    
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var backGroundLabel: UILabel!

    private var subscriberDictionaryList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Updating..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        backGroundLabel = {
            let label = UILabel()
            label.text = "no subscribers yet"
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
    }
    
    func retreiveSubscribers() {
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        var parameters = [String: String] ()
        parameters["orgId"] = String(Organization.current!.id)
        
        let url = URL.with(base: API_BASE_URL, API_Name: "account/ListSubscribers", parameters: parameters)!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let subscriberList = try? JSON(data: data!).arrayValue {
                for subscriberData in subscriberList {
                    let subscriber = User(userInfo: subscriberData)
                    //store this User
                    self.subscriberDictionaryList.append(subscriber)
                }
            }
            
            
            
        }
    }
    
}
