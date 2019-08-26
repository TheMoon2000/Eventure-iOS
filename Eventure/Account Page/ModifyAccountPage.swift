//
//  ModifyAccountPage.swift
//  Eventure
//
//  Created by jeffhe on 2019/8/24.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

import UIKit

class ModifyAccountPage: UIViewController {
    
    private var myTextBox: UITextField!
    private var type: String!
    private var predisplay: String!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var spinnerLabelText: String!
    private var titleLabel: UILabel!
    private var titleLabelText: String!
    
    init(type: String) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        if (type == "Name"){
            predisplay = User.current!.displayedName
            spinnerLabelText = "Changing your name..."
            titleLabelText = "Change your displayed name."
        } else if type == "Password" {
            predisplay = ""
            spinnerLabelText = "Changing your password..."
            titleLabelText = "Change your password"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        
        
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
            label.text = spinnerLabelText
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        myTextBox = {
            let myTextBox = UITextField()
            myTextBox.text = predisplay
            myTextBox.keyboardType = .emailAddress
            myTextBox.adjustsFontSizeToFitWidth = true
            myTextBox.textContentType = .emailAddress
            myTextBox.returnKeyType = .next
            prepareField(textfield: myTextBox)
            myTextBox.translatesAutoresizingMaskIntoConstraints = false
            if (type == "Password") {
                myTextBox.isSecureTextEntry = true
            }
            self.view.addSubview(myTextBox)
            
            myTextBox.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            myTextBox.heightAnchor.constraint(equalToConstant: 45).isActive = true
            myTextBox.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            myTextBox.topAnchor.constraint(equalTo: view.centerYAnchor,
                                     constant: -320).isActive = true
            
            return myTextBox
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.textColor = UIColor.gray
            label.text = titleLabelText
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.leftAnchor,constant:15).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant:100).isActive = true
            
            return label
        } ()
        
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(changeInfo))
        
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

    @objc private func changeInfo() {
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        
        let newInfo : String = myTextBox.text!
        
        let urlParameter = [
            "uuid": String(User.current!.uuid)
        ]
        
        // Make the URL and URL request
        let apiURL = URL.with(base: API_BASE_URL,
                              API_Name: "account/UpdateUserInfo",
                              parameters: urlParameter)!
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addAuthHeader()
        
        // Construct JSON
        var body = JSON()
        if type == "Name" {
            body.dictionaryObject?["Displayed name"] = myTextBox.text!
        } else if type == "Password" {
            print(MD5(string:myTextBox.text!))
            body.dictionaryObject?["Password MD5"] = MD5(string:myTextBox.text!)
        }
        request.httpBody = try? body.rawData()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
                self.navigationController?.popViewController(animated: true)
            }

            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            //for POST json, we parse data with the following way
            if let status = String(data: data!, encoding: .ascii) {
                if status != "success" {
                    DispatchQueue.main.async {
                        if status == "internal error" {
                            serverMaintenanceError(vc: self)
                            return
                        }
                        
                        let alert = UIAlertController(title: "Error", message: status, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    if self.type == "Name" {
                        User.current!.displayedName = newInfo
                    }
                }
            }
        }
        task.resume()
    }
    
    func MD5(string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
