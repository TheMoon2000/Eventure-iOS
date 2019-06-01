//
//  LoginViewController.swift
//  Eventure
//
//  Created by Xiang Li on 5/29/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController {
    var canvas: UIScrollView!
    var usr = CustomTextField()
    var pswd = CustomTextField()
    var loginButton = UIButton(type: .custom)
    var customKeyboardAccessory: UIView!
    var activeField: CustomTextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = MAIN_TINT
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.makeAccessoryView()
        self.setupCanvas()
        self.setupLogins()
        
        // Setup keyboard show/hide observers
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // UI setup
    
    private func makeAccessoryView() {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.92, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                         constant: -20).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        customKeyboardAccessory = view
    }
    
    private func setupCanvas() {
        canvas = UIScrollView()
        canvas.bounces = true
        canvas.showsVerticalScrollIndicator = true
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.keyboardDismissMode = .interactive
        view.addSubview(canvas)
        
        canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func prepareField(textfield: UITextField) {
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.clearButtonMode = .whileEditing
        textfield.inputAccessoryView = customKeyboardAccessory
        textfield.backgroundColor = .white
        textfield.layer.borderColor = MAIN_TINT_DARK.withAlphaComponent(0.8).cgColor
        textfield.layer.borderWidth = 1.8
    }
    
    private func setupLogins() {
        usr.delegate = self
        usr.placeholder = "Username / Email"
        usr.keyboardType = .emailAddress
        usr.adjustsFontSizeToFitWidth = true
        usr.returnKeyType = .next
        prepareField(textfield: usr)
        
        pswd.delegate = self
        pswd.placeholder = "password"
        pswd.isSecureTextEntry = true
        pswd.returnKeyType = .done
        prepareField(textfield: pswd)
        
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        loginButton.tintColor = .white
        loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        loginButton.layer.cornerRadius = 0 //18
        
        canvas.addSubview(usr)
        canvas.addSubview(pswd)
        canvas.addSubview(loginButton)
        
        pswd.translatesAutoresizingMaskIntoConstraints = false
        usr.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Let pswd be the center anchor
        
        pswd.widthAnchor.constraint(equalToConstant: 240).isActive = true
        pswd.heightAnchor.constraint(equalToConstant: 45).isActive = true
        pswd.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        pswd.centerYAnchor.constraint(equalTo: canvas.centerYAnchor).isActive = true
        
        usr.widthAnchor.constraint(equalToConstant: 240).isActive = true
        usr.heightAnchor.constraint(equalToConstant: 45).isActive = true
        usr.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        usr.centerYAnchor.constraint(equalTo: pswd.centerYAnchor,
                                     constant: -50).isActive = true
        
        loginButton.widthAnchor.constraint(equalTo: pswd.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: pswd.centerYAnchor, constant: 66).isActive = true
        
        //login/register transition page
        loginButton.addTarget(self,
                              action: #selector(beginLoginRequest),
                              for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(buttonPressed(_:)),
                              for: .touchDown)
        loginButton.addTarget(self, action: #selector(buttonLifted(_:)),
                              for: [.touchUpOutside, .touchDragExit])
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(1.0)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
    }
    
    @objc private func beginLoginRequest() {
        
        // First verifies that the username and password are not blank
        guard let username = usr.text, username != "" else {
            print("username is empty")
            return
        }
        
        guard let password = pswd.text, password != "" else {
            print("password is empty")
            return
        }
        
        // Change the button style to reflect that a login request is in progress
        loginButton.isEnabled = false
        loginButton.setTitle("Signing In...", for: .normal)
        loginButton.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        
        // Construct the URL parameters to be delivered
        let loginParameters = [
            "login": username,
            "password": password
        ]
        
        // Make the URL and URL request
        let apiURL = URL.with(base: API_BASE_URL,
                              API_Name: "account/Authenticate",
                              parameters: loginParameters)!
        var request = URLRequest(url: apiURL)
        let token = "\(USERNAME):\(PASSWORD)".data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loginButton.setTitleColor(.white, for: .normal)
                self.loginButton.setTitle("Sign In", for: .normal)
                self.loginButton.isEnabled = true
            }
            
            guard error == nil else {
                print(error!); return
            }
            
            if let json = try? JSON(data: data!) {
                print(json)
                // TODO: determine if login is successful or not
                // Write code here...
            } else {
                // handles internet / server errors
                print("Could not parse JSON data")
            }
        }
        
        task.resume()
        
    }
    
    
    // Notification handlers
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        let kbSize = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as! CGRect).size
        canvas.contentInset.bottom = kbSize.height
        canvas.scrollIndicatorInsets.bottom = kbSize.height
        if let textfield = activeField {
            // Determine whether additional space is needed to fully display the keyboard
            let bottomSpace = max(0, kbSize.height - canvas.frame.height +  textfield.frame.maxY + 8)
            canvas.contentOffset.y = bottomSpace
        }
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        canvas.contentInset = .zero
        canvas.scrollIndicatorInsets = .zero
        canvas.contentOffset.y = 0
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


// Add editing events detection

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField as? CustomTextField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usr) {
            pswd.becomeFirstResponder()
        } else {
            self.dismissKeyboard()
        }
        return true
    }
}


/// A special subclass of UITextField that adds 10 pixels of inset in the horizontal direction.
class CustomTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .zero)
    }
}
