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
    let authUsr = "eventure-frontend"
    let authPswd = "MeiYouMiMa"
    var canvas: UIScrollView!
    var usr = UITextField()
    var pswd = UITextField()
    var loginButton = UIButton(type: .system)
    var registerButton = UIButton(type: .system)
    var activeField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.view.backgroundColor = MAIN_TINT
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.setupCanvas()
        self.setupLogins()
        
        // Setup keyboard show/hide observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // UI setup
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
        textfield.backgroundColor = .white
        textfield.borderStyle = .roundedRect
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textfield.frame.height))
        textfield.leftView = inset
        textfield.leftViewMode = .always
    }
    
    private func setupLogins() {
        usr.delegate = self
        usr.placeholder = "Username / Email"
        usr.keyboardType = .emailAddress
        usr.adjustsFontSizeToFitWidth = true
        usr.returnKeyType = .next
        prepareField(textfield: usr)
        
        pswd.delegate = self
        pswd.placeholder = "Password"
        pswd.textContentType = .password
        pswd.isSecureTextEntry = true
        pswd.returnKeyType = .go
        prepareField(textfield: pswd)
        
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        loginButton.tintColor = .white
        loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        loginButton.layer.cornerRadius = 18
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        registerButton.tintColor = .white
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 2.0

        canvas.addSubview(usr)
        canvas.addSubview(pswd)
        canvas.addSubview(loginButton)
        canvas.addSubview(registerButton)
        
        pswd.translatesAutoresizingMaskIntoConstraints = false
        usr.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Let pswd be the center anchor
        
        pswd.widthAnchor.constraint(equalToConstant: 210).isActive = true
        pswd.heightAnchor.constraint(equalToConstant: 45).isActive = true
        pswd.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        pswd.centerYAnchor.constraint(equalTo: canvas.centerYAnchor).isActive = true
        
        usr.widthAnchor.constraint(equalToConstant: 210).isActive = true
        usr.heightAnchor.constraint(equalToConstant: 45).isActive = true
        usr.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        usr.centerYAnchor.constraint(equalTo: pswd.centerYAnchor,
                                     constant: -50).isActive = true
        
        loginButton.widthAnchor.constraint(equalToConstant: 186).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: pswd.centerYAnchor, constant: 65).isActive = true
        
        registerButton.widthAnchor.constraint(equalToConstant: 93).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
        //login/register transition page
        loginButton.addTarget(self, action: #selector(buttonLifted(_:)),
                              for: [.touchUpOutside, .touchDragExit, .touchDragExit, .touchCancel])
        loginButton.addTarget(self,
                              action: #selector(beginLoginRequest),
                              for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(buttonPressed(_:)),
                              for: .touchDown)
    }
    
    
    // Button appearance
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(1.0)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
    }
    
    
    
    @objc private func beginLoginRequest() {
        dismissKeyboard()
        let reset = {
            self.loginButton.setTitleColor(.white, for: .normal)
            self.loginButton.setTitle("Sign In", for: .normal)
            self.loginButton.isEnabled = true
            self.loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        }
        
        // First verifies that the username and password are not blank
        guard let username = usr.text, username != "" else {
            print("username is empty")
            reset()
            return
        }
        
        guard let password = pswd.text, password != "" else {
            print("password is empty")
            reset()
            return
        }
        
        // Change the button style to reflect that a login request is in progress
        loginButton.isEnabled = false
        loginButton.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        loginButton.setTitle("Signing In...", for: .normal)
        loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(1.0)
        
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

        let token = "\(authUsr):\(authPswd)".data(using: .utf8)!.base64EncodedString()
        request.httpMethod = "POST"
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                reset()
            }
            
            guard error == nil else {
                print(error!); return
            }
            
            do {
                let result = try JSON(data: data!).dictionary
                let servermsg = result?["status"]?.rawString()
                print(servermsg!)
                if (servermsg == "success") {
                    let nextVC = MainTabBarController()
                    self.present(nextVC, animated: true, completion: nil)
                } else {
                    //UI related events belong in main thread
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Login Error", message: servermsg, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("error parsing")
            }
        }
        task.resume()
        
    }
    
    @objc private func registerPressed() {
        let nextVC = RegisterViewController()
        self.present(nextVC, animated: true, completion: nil)
    }
    // Notification handlers to make sure that the active textfield is always visible

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
        canvas.endEditing(true)
    }
}    
    


// Add editing events detection
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField as? UITextField
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
