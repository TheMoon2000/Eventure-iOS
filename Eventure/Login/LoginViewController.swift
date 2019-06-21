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
    var usr = UITextField()
    var pswd = UITextField()
    var loginButton = UIButton(type: .system)
    var registerButton = UIButton(type: .system)
    var forgotButton = UIButton(type: .system)
    var activeField: UITextField?
    var logo = UIImageView()
    
    
    // Make the status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //self.view.backgroundColor = MAIN_TINT3
        let topColor = MAIN_TINT8
        let buttomColor = MAIN_TINT6
        let gradientColors = [topColor.cgColor, buttomColor.cgColor]
        
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = self.view.frame
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.setupCanvas()
        self.setupLogins()
        canvas.contentOffset = .zero
        
        // Setup keyboard show/hide observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        // to detect rotation change and any kind of unexpected UI changes/lack of changes
        // NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //this will be called when the next VC is rotated and switched back to this one
        rotated(frame: view.frame)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        rotated(frame: CGRect(origin: .zero, size: size))
    }
    
    // UI setup
    private func setupCanvas() {
        canvas = UIScrollView()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.keyboardDismissMode = .interactive
        view.addSubview(canvas)
        
        canvas.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        canvas.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    //TODO: FIX THE ROTATION GLITCH
    func rotated(frame: CGRect?) {
        //see viewWillAppear for another call to this method
        //seems like at launch this will be called twice for some reason
        let topColor = MAIN_TINT8
        let buttomColor = MAIN_TINT6
        let gradientColors = [topColor.cgColor, buttomColor.cgColor]
        
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = frame ?? UIScreen.main.bounds
        
        self.view.layer.replaceSublayer(self.view.layer.sublayers![0], with: gradientLayer)
    }
    
    
    /// Set up a textfield.
    
    private func prepareField(textfield: UITextField) {
        textfield.delegate = self
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
    
    
    /// Set up the UI elements from top to bottom.
    
    private func setupLogins() {
        
        // Logo image
        
        logo.image = #imageLiteral(resourceName: "logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(logo)
        
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        logo.widthAnchor.constraint(equalToConstant: 290).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 160).isActive = true
        logo.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
//        logo.topAnchor.constraint(greaterThanOrEqualTo: canvas.topAnchor,
//                                  constant: -15).isActive = true
        let c = logo.centerYAnchor.constraint(equalTo: canvas.centerYAnchor,
                                              constant: -156)
        c.priority = .defaultLow
        c.isActive = true
        
        // Username field
        
        usr.placeholder = "Email"
        usr.keyboardType = .emailAddress
        usr.adjustsFontSizeToFitWidth = true
        usr.returnKeyType = .next
        prepareField(textfield: usr)
        usr.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(usr)

        usr.widthAnchor.constraint(equalToConstant: 230).isActive = true
        usr.heightAnchor.constraint(equalToConstant: 45).isActive = true
        usr.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        usr.topAnchor.constraint(equalTo: logo.bottomAnchor,
                                 constant: 3).isActive = true
        
        
        // Password field
            
        pswd.placeholder = "Password"
        pswd.isSecureTextEntry = true
        pswd.returnKeyType = .go
        prepareField(textfield: pswd)
        pswd.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(pswd)
        
        pswd.widthAnchor.constraint(equalTo: usr.widthAnchor).isActive = true
        pswd.heightAnchor.constraint(equalTo: usr.heightAnchor).isActive = true
        pswd.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        pswd.topAnchor.constraint(equalTo: usr.bottomAnchor,
                                  constant: 8).isActive = true
        
        
        // Sign in button
        
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17.2, weight: .semibold)
        loginButton.tintColor = .white
        loginButton.backgroundColor = .init(white: 1, alpha: 0.05)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(loginButton)
        
        loginButton.widthAnchor.constraint(equalTo: usr.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: pswd.bottomAnchor,
                                             constant: 32).isActive = true
        
        
        // Vertical separator
        
        let separator = UIView()
        separator.backgroundColor = .init(white: 1, alpha: 0.7)
        separator.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(separator)
        
        separator.widthAnchor.constraint(equalToConstant: 1.6).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 28).isActive = true
        separator.bottomAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -14).isActive = true
        separator.centerXAnchor.constraint(equalTo: canvas.centerXAnchor, constant: -18).isActive = true
        separator.topAnchor.constraint(greaterThanOrEqualTo: loginButton.bottomAnchor,
                                       constant: 25).isActive = true
        
        
        // Register button
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        registerButton.tintColor = .init(white: 1, alpha: 0.95)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.addTarget(self,
                                 action: #selector(registerPressed),
                                 for: .touchUpInside)
        canvas.addSubview(registerButton)
        
        registerButton.centerYAnchor.constraint(equalTo: separator.centerYAnchor).isActive = true
        registerButton.rightAnchor.constraint(equalTo: separator.leftAnchor,
                                              constant: -45).isActive = true
        
        forgotButton.setTitle("Forgot Password", for: .normal)
        forgotButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        forgotButton.tintColor = .init(white: 1, alpha: 0.95)
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        canvas.addSubview(forgotButton)
        
        forgotButton.centerYAnchor.constraint(equalTo: separator.centerYAnchor).isActive = true
        forgotButton.leftAnchor.constraint(equalTo: separator.rightAnchor,
                                           constant: 44).isActive = true

        
        //login/register transition page
        
        loginButton.addTarget(self, action: #selector(buttonLifted(_:)),
                              for: [.touchUpOutside, .touchDragExit, .touchDragExit, .touchCancel])
        loginButton.addTarget(self,
                              action: #selector(beginLoginRequest),
                              for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(buttonPressed(_:)),
                              for: .touchDown)
        forgotButton.addTarget(self, action: #selector(forgotPSWD), for: .touchDown)
    }
    
    
    // Button appearance
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        sender.backgroundColor = UIColor(white: 1, alpha: 0.15)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .clear
        //sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
    }
    
    @objc private func forgotPSWD(_ sender: UIButton) {
        let nextVC = ForgotPassword() // ForgotPSWDViewController()
        nextVC.loginView = self
//        self.navigationController?.pushViewController(nextVC, animated: true)
        self.present(nextVC, animated: true, completion: nil)
    }
    
    @objc private func beginLoginRequest() {
        dismissKeyboard()
        let reset = {
            self.loginButton.setTitleColor(.white, for: .normal)
            self.loginButton.setTitle("Sign In", for: .normal)
            self.loginButton.isEnabled = true
            self.loginButton.backgroundColor = .clear
            //self.loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        }
        
        // First verifies that the username and password are not blank
        guard let username = usr.text, username != "" else {
            print("username is empty")
            usr.shake()
            reset()
            return
        }
        
        guard let password = pswd.text, password != "" else {
            print("password is empty")
            pswd.shake()
            reset()
            return
        }
        
        // Change the button style to reflect that a login request is in progress
        loginButton.isEnabled = false
        loginButton.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        loginButton.setTitle("Signing In...", for: .normal)
        loginButton.backgroundColor = .clear
        //loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(1.0)
        
        // Construct the URL parameters to be delivered
        let loginParameters = [
            "email": username,
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
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
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
        let nextVC = RegisterTableController() // RegisterController()
        nextVC.loginView = self
//        let nav = UINavigationController(rootViewController: nextVC)
        self.present(nextVC, animated: true, completion: nil)
    }
    
    
    // Notification handlers to make sure that the active textfield is always visible

    @objc private func keyboardDidShow(_ notification: Notification) {
        let kbSize = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as! CGRect).size
        canvas.contentInset.bottom = kbSize.height
        canvas.scrollIndicatorInsets.bottom = kbSize.height
        if let textfield = activeField {
            // Determine whether additional space is needed to fully display the keyboard
            let bottomSpace = max(0, kbSize.height - view.frame.height +  textfield.frame.maxY + 8)
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
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == usr) {
            pswd.becomeFirstResponder()
        } else {
            beginLoginRequest()
            self.dismissKeyboard()
        }
        return true
    }
}
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
