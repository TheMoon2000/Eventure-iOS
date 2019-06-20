//
//  ForgotPSWDViewController.swift
//  Eventure
//
//  Created by Xiang Li on 6/18/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// TOOD: Rewrite the forgot password page using UITableViewController

class ForgotPSWDViewController: UIViewController {
    var canvas: UIScrollView!
    var forgot = UITextField()
    var retrieveButton = UIButton(type: .system)
    var activeField: UITextField?
    let authforgot = "__replace__"
    let authPswd = "__replace__"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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

        // Do any additional setup after loading the view.
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
        forgot.delegate = self
        forgot.placeholder = "Enter Email for Password"
        forgot.keyboardType = .emailAddress
        forgot.adjustsFontSizeToFitWidth = true
        forgot.returnKeyType = .next
        prepareField(textfield: forgot)
        
        retrieveButton.setTitle("Send Email", for: .normal)
        retrieveButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        retrieveButton.tintColor = .white
        retrieveButton.backgroundColor = .clear
        retrieveButton.layer.cornerRadius = 5
        retrieveButton.layer.borderColor = UIColor.white.cgColor
        retrieveButton.layer.borderWidth = 2.0
        
        canvas.addSubview(forgot)
        canvas.addSubview(retrieveButton)
        
        forgot.translatesAutoresizingMaskIntoConstraints = false
        retrieveButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Let pswd be the center anchor
        
        forgot.widthAnchor.constraint(equalToConstant: 210).isActive = true
        forgot.heightAnchor.constraint(equalToConstant: 40).isActive = true
        forgot.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
        forgot.centerYAnchor.constraint(equalTo: canvas.centerYAnchor,
                                     constant: -50).isActive = true
        
        
        retrieveButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        retrieveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        retrieveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        retrieveButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 45).isActive = true
        
        
        //login/register transition page
        retrieveButton.addTarget(self, action: #selector(buttonLifted(_:)),
                              for: [.touchUpOutside, .touchDragExit, .touchDragExit, .touchCancel])
        retrieveButton.addTarget(self,
                              action: #selector(beginLoginRequest),
                              for: .touchUpInside)
        retrieveButton.addTarget(self, action: #selector(buttonPressed(_:)),
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
    }
    
    @objc private func beginLoginRequest() {
        dismissKeyboard()
        let reset = {
            self.retrieveButton.setTitleColor(.white, for: .normal)
            self.retrieveButton.setTitle("Send Email", for: .normal)
            self.retrieveButton.isEnabled = true
            self.retrieveButton.backgroundColor = .clear
        }
        
        // First verifies that the username and password are not blank
        guard let username = forgot.text, username != "" else {
            print("username is empty")
            forgot.shake()
            reset()
            return
        }
        
        // Change the button style to reflect that a login request is in progress
        retrieveButton.isEnabled = false
        retrieveButton.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        retrieveButton.setTitle("Sending...", for: .normal)
        retrieveButton.backgroundColor = .clear
        
        // Construct the URL parameters to be delivered
        let loginParameters = [
            "email": username
        ]
        
        // Make the URL and URL request
        let apiURL = URL.with(base: API_BASE_URL,
                              API_Name: "account/Authenticate",
                              parameters: loginParameters)!
        var request = URLRequest(url: apiURL)
        
        let token = "\(authforgot):\(authPswd)".data(using: .utf8)!.base64EncodedString()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


extension ForgotPSWDViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}
