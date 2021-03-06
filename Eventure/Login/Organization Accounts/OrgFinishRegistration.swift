//
//  OrgFinishRegistration.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/5.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class OrgFinishRegistration: UIViewController {

    /// A copy of the information the user entered on the registration page.
    var registrationData: OrganizationRegistrationData!
    
    /// The parent view controller.
    var regVC: RegisterOrganization!
    
    private var spinner: UIActivityIndicatorView!
    private var spinnerCaption: UILabel!
    private var button: UIButton!
    private var completionImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.background
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = UIColor(white: 0.75, alpha: 1)
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                             constant: -25).isActive = true
            return spinner
        }()
        
        spinnerCaption = {
            let label = UILabel()
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.text = "Creating your Account..."
            label.font = .appFontRegular(18)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor,
                                       constant: 24).isActive = true
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                        constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                         constant: -30).isActive = true
            
            return label
        }()
        
        button = {
            let button = UIButton(type: .system)
            button.tintColor = AppColors.main
            button.isHidden = true
            button.titleLabel?.font = .appFontMedium(19)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 220).isActive = true
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -29).isActive = true
            
            button.addTarget(self, action: #selector(returnToLogin), for: .touchUpInside)
            
            return button
        }()
        
        completionImage = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            
            imageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            imageView.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: spinner.centerYAnchor).isActive = true
            
            return imageView
        }()
        
        createAccount()
    }
    
    
    @objc private func returnToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        if sender.title(for: .normal) == "Return to Login" {
            regVC.navigationController?.popViewController(animated: true)
            let alert = UIAlertController(title: "New Account Requires Activation", message: "Please check your inbox to verify your email address and activate your organization account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.regVC?.loginView?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /**
     Displays a failure message.
     
     - Parameters:
     - msg: The failure message to display to the user.
     */
    
    private func failed(msg: String) {
        spinner.stopAnimating()
        spinnerCaption.text = msg
        button.isHidden = false
        button.setTitle("Return to Registration", for: .normal)
        completionImage.image = #imageLiteral(resourceName: "error")
    }
    
    
    /// Displays the success message.
    
    private func succeeded() {
        spinner.stopAnimating()
        spinnerCaption.text = "Your organization account was created!"
        button.isHidden = false
        button.setTitle("Return to Login", for: .normal)
        completionImage.image = #imageLiteral(resourceName: "done")
    }
    
    
    /// Initiates an API call to `account/Register` with the information provided by the user.
    
    private func createAccount() {
        
        let url = URL(string: API_BASE_URL + "account/RegisterOrg")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addMultipartBody(parameters: registrationData.parameters, files: registrationData.fileData)
                
        // Authentication
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print("Account registration error: " + error!.localizedDescription)
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self, handler: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                return
            }
            
            if let str = String(data: data!, encoding: .utf8) {
                DispatchQueue.main.async {
                    if str == "success" {
                        self.succeeded()
                    } else {
                        self.failed(msg: str)
                    }
                }
            }
        }
        
        task.resume()
        
    }
}
