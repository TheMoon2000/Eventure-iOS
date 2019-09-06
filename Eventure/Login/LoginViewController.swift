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
    var usr: UITextField!
    var pswd: UITextField!
    var loginButton: UIButton!
    var loginAsGuest: UIButton!
    var registerButton: UIButton!
    var forgotButton: UIButton!
    var activeField: UITextField?
    var logo: UIImageView!
    
    var navBar: UINavigationController?
    
    // Make the status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Setup
    
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
    
        canvas = {
            let canvas = UIScrollView()
            canvas.translatesAutoresizingMaskIntoConstraints = false
            canvas.keyboardDismissMode = .interactive
            view.addSubview(canvas)
            
            canvas.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo:
                view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        self.setupLogins()
        
        // Setup keyboard show/hide observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
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
        coordinator.animate(alongsideTransition: { context in
            self.loginAsGuest.isHidden = size.height < 500
        }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
        
        logo = {
            let logo = UIImageView()
            logo.image = #imageLiteral(resourceName: "logo")
            logo.contentMode = .scaleAspectFit
            logo.clipsToBounds = true
            logo.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(logo)
            
            logo.widthAnchor.constraint(equalToConstant: 290).isActive = true
            logo.heightAnchor.constraint(equalToConstant: 160).isActive = true
            logo.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            logo.topAnchor.constraint(greaterThanOrEqualTo: canvas.topAnchor,
                                      constant: -35).isActive = true
            let c = logo.centerYAnchor.constraint(equalTo: canvas.centerYAnchor,
                                                  constant: -156)
            c.priority = .defaultLow
            c.isActive = true
            
            return logo
        }()
        
        
        // Username field
        
        usr = {
            let usr = UITextField()
            usr.placeholder = "Email / Organization ID"
            usr.keyboardType = .emailAddress
            usr.adjustsFontSizeToFitWidth = true
            usr.textContentType = .emailAddress
            usr.returnKeyType = .next
            prepareField(textfield: usr)
            usr.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(usr)
            
            usr.widthAnchor.constraint(equalToConstant: 240).isActive = true
            usr.heightAnchor.constraint(equalToConstant: 45).isActive = true
            usr.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            usr.topAnchor.constraint(equalTo: logo.bottomAnchor,
                                     constant: 3).isActive = true
            
            return usr
        }()
        
        
        // Password field
            
        pswd = {
            let pswd = UITextField()
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
            
            return pswd
        }()
        
        
        // Sign in button
        
        loginButton = {
            let button = UIButton(type: .system)
            button.setTitle("Sign In", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17.2, weight: .semibold)
            button.tintColor = .white
            button.backgroundColor = .init(white: 1, alpha: 0.05)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1.0
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.widthAnchor.constraint(equalTo: usr.widthAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            button.topAnchor.constraint(lessThanOrEqualTo: pswd.bottomAnchor, constant: 32).isActive = true
            button.topAnchor.constraint(greaterThanOrEqualTo: pswd.bottomAnchor, constant: 20).isActive = true
            
            // Actions
            button.addTarget(self,
                             action: #selector(buttonLifted(_:)),
                             for: [.touchUpOutside, .touchDragExit, .touchDragExit, .touchCancel])
            button.addTarget(self,
                             action: #selector(beginLoginRequest),
                             for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonPressed(_:)),
                             for: .touchDown)
            
            return button
        }()
        
        loginAsGuest = {
            let button = UIButton(type: .system)
            button.setTitle("Continue as Guest", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.tintColor = .init(white: 1, alpha: 0.95)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            canvas.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            button.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15).isActive = true
            
            button.addTarget(self, action: #selector(continueAsGuest), for: .touchUpInside)
            
            return button
        }()
        
        
        let bottomStack: UIStackView = {
            let stack = UIStackView()
            stack.alignment = .center
            stack.spacing = 25
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            
            stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
            stack.topAnchor.constraint(greaterThanOrEqualTo: loginButton.bottomAnchor, constant: 15).isActive = true
            
            return stack
        }()
        
        
        // Register button
        
        registerButton = {
            let button = UIButton(type: .system)
            button.setTitle("Register", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.tintColor = .init(white: 1, alpha: 0.9)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            bottomStack.addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(registerPressed), for: .touchUpInside)
            
            return button
        }()
        
        // Vertical separator
        
        let separator = UIView()
        separator.backgroundColor = .init(white: 1, alpha: 0.7)
        separator.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.addArrangedSubview(separator)
        
        separator.widthAnchor.constraint(equalToConstant: 1.6).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        forgotButton = {
            let button = UIButton(type: .system)
            button.setTitle("Forgot Password", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.tintColor = .init(white: 1, alpha: 0.95)
            button.translatesAutoresizingMaskIntoConstraints = false
            bottomStack.addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(forgotPSWD), for: .touchUpInside)
            
            return button
        }()
        
    }
    
    // MARK: - Button actions
    
    @objc private func continueAsGuest() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        sender.backgroundColor = UIColor(white: 1, alpha: 0.1)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .clear
        //sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
    }
    
    @objc private func forgotPSWD(_ sender: UIButton) {
        let nextVC = ForgotPassword() // ForgotPSWDViewController()
        nextVC.loginView = self
        self.navigationController?.pushViewController(nextVC, animated: true)
//        self.present(nextVC, animated: true, completion: nil)
    }
    
    // MARK: - Begin login request
    
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
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                reset()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            do {
                let result = try JSON(data: data!).dictionary
                let servermsg = result?["status"]?.stringValue
                if (servermsg == "success") {
                    var userObject: User?
                    var orgObject: Organization?
                    if let userInfo = result!["user info"] {
                        userObject = User(userInfo: userInfo)
                        UserDefaults.standard.setValue(ACCOUNT_TYPE_USER, forKey: KEY_ACCOUNT_TYPE)
                    }
                    if let orgInfo = result!["org info"] {
                        orgObject = Organization(orgInfo: orgInfo)
                        UserDefaults.standard.setValue(ACCOUNT_TYPE_ORG, forKey: KEY_ACCOUNT_TYPE)
                    }
                    DispatchQueue.main.async {
                        self.handleLoginResults(user: userObject, org: orgObject)
                    }
                } else {
                    DispatchQueue.main.async {
                        if servermsg == INTERNAL_ERROR {
                            serverMaintenanceError(vc: self)
                            return
                        }
                        
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
    
    private func handleLoginResults(user: User?, org: Organization?) {
        
        func handleUserLogin(user: User) {
            User.current = user
            
            if user.tags.isEmpty {
                let nextVC = TagPickerView()
                nextVC.loginVC = self
                present(nextVC, animated: true, completion: nil)
            } else {
                MainTabBarController.current.openScreen()
            }
        }
        
        func handleOrgLogin(org: Organization) {
            Organization.current = org
            Organization.current?.save()
            MainTabBarController.current.openScreen(isUserAccount: false)
        }
        
        if user == nil {
            handleOrgLogin(org: org!)
        } else if org == nil {
            handleUserLogin(user: user!)
        } else {
            let alert = UIAlertController(title: "Multiple Accounts Detected", message: "The login credential is associated with both a user account and an organization account. Which identity would you like to sign in as?", preferredStyle: .actionSheet)
            let username = user!.displayedName == user!.email ? "user" : user!.displayedName
            alert.addAction(.init(title: "As \(username)", style: .default, handler: {
                action in
                
                DispatchQueue.main.async {
                    handleUserLogin(user: user!)
                }
            }))
            
            alert.addAction(.init(title: "As '\(org!.title)'", style: .default, handler: { action in
                
                DispatchQueue.main.async {
                    handleOrgLogin(org: org!)
                }
            }))
            
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    @objc private func registerPressed() {
        
        let handler: ((UIAlertAction) -> Void) = { action in
            let nextVC: UIViewController
            if action.title == "User Account" {
                let vc = RegisterTableController() // RegisterController()
                vc.loginView = self
                nextVC = vc
            } else {
                let vc = RegisterOrganization()
                vc.loginView = self
                nextVC = vc
            }
            self.navBar?.pushViewController(nextVC, animated: true)
        }
        
        let alert = UIAlertController(title: "What type of account do you want?", message: "A user account is used for engaging with events; an organization account is used for publishing event posts.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "User Account", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Organization Account", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    // MARK: - Keyboard events

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
    


// MARK: - Editing events detection

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

// MARK: - Add shake effect

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
