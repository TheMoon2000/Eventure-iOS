//
//  ForgotPassword.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForgotPassword: UITableViewController {
    
    private let buttonTitle = "Send Reset Email"
    private var contentCells = [UITableViewCell]()
    
    var loginView: LoginViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.showsHorizontalScrollIndicator = false
        tableView.tintColor = MAIN_TINT
        
        let navCell: UITableViewCell = {
            let cell = NavBackCell()
            cell.action = closeVC
            return cell
        }()
        contentCells.append(navCell)
        
        let messageCell: UITableViewCell = {
            let cell = MessageCell()
            cell.title = "Forgot Password"
            cell.caption = "If the provided email is associated with an account, we will send you a link for you to reset your password."
            
            return cell
        }()
        contentCells.append(messageCell)
        
        let emailCell: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Email / Org. Account ID"
            cell.textField.autocorrectionType = .no
            cell.textField.enablesReturnKeyAutomatically = true
            cell.textField.keyboardType = .emailAddress
            cell.textField.textContentType = .username
            cell.textField.returnKeyType = .send
            
            cell.changeHandler = { cell in
                let buttonCell = self.contentCells[3] as! ButtonCell
                
                if !cell.textField.text!.isEmpty {
                    buttonCell.button.isEnabled = true
                    buttonCell.button.alpha = 1.0
                } else {
                    buttonCell.button.isEnabled = false
                    buttonCell.button.alpha = DISABLED_ALPHA
                }
            }
            
            cell.returnHandler = {
                self.submitRequest()
            }
            
            return cell
        }()
        contentCells.append(emailCell)
        
        // 3
        let buttonCell: UITableViewCell = {
            let cell = ButtonCell(width: 270)
            cell.button.setTitle(buttonTitle, for: .normal)
            
            cell.primaryAction = {
                self.submitRequest()
            }
            
            cell.button.isEnabled = false
            cell.button.alpha = DISABLED_ALPHA
            
            return cell
        }()
        contentCells.append(buttonCell)
    }
    
    @objc private func closeVC() {
        loginView?.navBar?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 2, 1][section]
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return contentCells[0] // Navigation cell
        case (1, 0):
            return contentCells[1] // Message cell
        case (1, 1):
            return contentCells[2] // Email / ID cell
        case (2, 0):
            return contentCells[3] // Button cell
        default:
            return UITableViewCell()
        }

    }
 
    private func submitRequest(type: String? = nil) {
        
        let id = (contentCells[2] as! MinimalTextCell).textField.text!
        
        guard !CharacterSet(charactersIn: id).isSubset(of: .whitespaces) else {
            contentCells[2].shake()
            return
        }
        
        tableView.endEditing(true)
        let buttonCell = contentCells[3] as! ButtonCell
        
        buttonCell.spinner.startAnimating()
        buttonCell.button.setTitle(nil, for: .normal)
        buttonCell.button.isEnabled = false
        buttonCell.button.alpha = DISABLED_ALPHA
        
        var parameters = ["login": id]
        
        if type != nil {
            parameters["type"] = type
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/ForgotPassword",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        
        // Authentication
        let token = "\(USERNAME):\(PASSWORD)".data(using: .ascii)!.base64EncodedString()
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                buttonCell.spinner.stopAnimating()
                buttonCell.button.setTitle(self.buttonTitle, for: .normal)
                buttonCell.button.isEnabled = true
                buttonCell.button.alpha = 1.0
            }
            
            guard error == nil else {
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        internetUnavailableError(vc: self!)
                    }
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8) ?? ""
            print(msg)
            switch msg {
            case "internal error":
                DispatchQueue.main.async { [weak self] in
                    if self != nil {
                        serverMaintenanceError(vc: self!)
                    }
                }
            case "invalid login":
                let alert = UIAlertController(title: "No Matches Found", message: "Your provided email address does not match an Eventure account. Please check that you have entered it correctly.", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            default:
                DispatchQueue.main.async { [weak self] in
                    self?.handleAccounts(returnString: msg)
                }
            }
        }
        
        task.resume()
    }
   
    private func handleAccounts(returnString: String) {
        
        func handleUser() {
            let alert = UIAlertController(title: "Reset Email Sent!", message: "Please check your inbox for instructions on how to reset your password.", preferredStyle: .alert)
            alert.addAction(.init(title: "Great", style: .default, handler: { action in
                DispatchQueue.main.async {
                    self.closeVC()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        
        func handleOrg() {
            let alert = UIAlertController(title: "Reset Email Sent!", message: "An email with instructions on how to reset your account's password has been sent to the contact email address that's associated with your organization.", preferredStyle: .alert)
            alert.addAction(.init(title: "Great", style: .default, handler: { action in
                DispatchQueue.main.async {
                    self.closeVC()
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        
        if returnString == "success: user" {
            handleUser()
        } else if returnString == "success: organization" {
            handleOrg()
        } else if let name = JSON(parseJSON: returnString).dictionary?["username"]?.string {
            let alert = UIAlertController(
                title: "Multiple Accounts Found",
                message: "We've found both a user account and an organization account associated with this login ID. Which account did you mean?", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "The User Account (\(name))", style: .default, handler: { action in
                DispatchQueue.main.async {
                    self.submitRequest(type: "user")
                }
            }))
            alert.addAction(.init(title: "The Organization Account", style: .default, handler: { action in
                DispatchQueue.main.async {
                    self.submitRequest(type: "org")
                }
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            print("Unidentified string: \(returnString)")
            let alert = UIAlertController(title: "Error", message: "An unknown error has occurred.", preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    

}
