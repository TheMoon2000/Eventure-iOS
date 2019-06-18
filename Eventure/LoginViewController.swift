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
    var forgotButton = UIButton(type: .system)
    var activeField: UITextField?
    var logo = UIImageView()
    
    
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
        
        // Setup keyboard show/hide observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        //to detect rotation change and any kind of unexpected UI changes/lack of changes
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //this will be called when the next VC is rotated and switched back to this one
        rotated()
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
    //TODO: FIX THE ROTATION GLITCH
    @objc private func rotated() {
        //see viewWillAppear for another call to this method
        //seems like at launch this will be called twice for some reason
        let topColor = MAIN_TINT8
        let buttomColor = MAIN_TINT6
        let gradientColors = [topColor.cgColor, buttomColor.cgColor]
        
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        gradientLayer.frame = self.view.frame
        self.view.layer.replaceSublayer(self.view.layer.sublayers![0], with: gradientLayer)
    }
    private func prepareField(textfield: UITextField) {
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.clearButtonMode = .whileEditing
        textfield.backgroundColor = .white
        textfield.borderStyle = .roundedRect
        textfield.doInset()
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
        //loginButton.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        loginButton.backgroundColor = .clear
        loginButton.layer.cornerRadius = 18
        //delete these
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 2.0
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        registerButton.tintColor = .white
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 2.0
        
        let forgotTitle =  NSAttributedString(string: "Forgot Password",
                                              attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize - 3)])
        forgotButton.setAttributedTitle(forgotTitle, for: .normal)
        forgotButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        forgotButton.tintColor = .white
        forgotButton.backgroundColor = .clear
        
        
        logo.image = UIImage(named: "logo")

        canvas.addSubview(usr)
        canvas.addSubview(pswd)
        canvas.addSubview(loginButton)
        canvas.addSubview(registerButton)
        canvas.addSubview(forgotButton)
        canvas.addSubview(logo)
        
        logo.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        logo.widthAnchor.constraint(equalToConstant: 300).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 250).isActive = true
        logo.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        logo.bottomAnchor.constraint(equalTo: usr.topAnchor, constant: 50).isActive = true
        
        pswd.translatesAutoresizingMaskIntoConstraints = false
        usr.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        logo.translatesAutoresizingMaskIntoConstraints = false
        
        //Let pswd be the center anchor
        
        pswd.widthAnchor.constraint(equalToConstant: 210).isActive = true
        pswd.heightAnchor.constraint(equalToConstant: 40).isActive = true
        pswd.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        pswd.centerYAnchor.constraint(equalTo: canvas.centerYAnchor).isActive = true
        
        usr.widthAnchor.constraint(equalToConstant: 210).isActive = true
        usr.heightAnchor.constraint(equalToConstant: 40).isActive = true
        usr.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        usr.centerYAnchor.constraint(equalTo: pswd.centerYAnchor,
                                     constant: -50).isActive = true
        
        loginButton.widthAnchor.constraint(equalToConstant: 210).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: pswd.centerYAnchor, constant: 65).isActive = true
        
        registerButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -45).isActive = true
        registerButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
        forgotButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        forgotButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        forgotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        forgotButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        forgotButton.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
        
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
        sender.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .clear
        //sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
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
        let nextVC = RegisterViewController()
        self.navigationController?.pushViewController(nextVC, animated: true)
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
        activeField = textField
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
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
