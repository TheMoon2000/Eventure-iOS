//
//  ForgotPassword.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ForgotPassword: UITableViewController {
    
    private let buttonTitle = "Send Reset Email"
    
    var loginView: LoginViewController?
    var email = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.showsHorizontalScrollIndicator = false
        tableView.tintColor = MAIN_TINT
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
        return UIView(frame: CGRect(x: 0,
                                    y: 0,
                                    width: 0,
                                    height: [10, 40, 0][section]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = NavBackCell()
            cell.action = closeVC
            return cell
        case (1, 0):
            let cell = MessageCell()
            cell.title = "Forgot Password"
            cell.caption = "If your provided email is associated with an account, we will send you a link for you to reset your password."
            
            return cell
        case (1, 1):
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Email Address"
            cell.textField.autocorrectionType = .no
            cell.textField.enablesReturnKeyAutomatically = true
            cell.textField.keyboardType = .emailAddress
            cell.textField.returnKeyType = .send
            cell.textField.text = email
            
            cell.changeHandler = {
                self.verifyEmail(cell: cell)
            }
            
            cell.returnHandler = {
                self.submitRequest()
            }
            
            return cell
        case (2, 0):
            let cell = ButtonCell(width: 270)
            cell.button.setTitle(buttonTitle, for: .normal)
            cell.altButton.setTitle("Back to Login", for: .normal)
            cell.altButton.isHidden = true
            
            cell.primaryAction = {
                self.submitRequest()
            }
            
            if !email.isValidEmail() {
                cell.button.isEnabled = false
                cell.button.alpha = DISABLED_ALPHA
            }
            
            return cell
        default:
            return UITableViewCell()
        }

    }
    
    /**
     Initiates email verification process on the given cell.
     
     - Parameters:
     - cell: The cell that contains the email address.
     - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyEmail(cell: MinimalTextCell) {
        
        email = cell.textField.text!
        
        guard let buttonCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ButtonCell else {
            preconditionFailure("The cell at section 2 row 0 shouldn't be empty")
        }
        
        if email.isValidEmail() {
            buttonCell.button.isEnabled = true
            buttonCell.button.alpha = 1.0
        } else {
            buttonCell.button.isEnabled = false
            buttonCell.button.alpha = DISABLED_ALPHA
        }
    
    }
 
    private func submitRequest() {
        
        guard email.isValidEmail() else {
            tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.shake()
            return
        }
        
        tableView.endEditing(true)
        guard let buttonCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ButtonCell else {
            preconditionFailure("The cell at section 1 row 0 shouldn't be empty")
        }
        
        buttonCell.spinner.startAnimating()
        buttonCell.button.setTitle(nil, for: .normal)
        buttonCell.button.isEnabled = false
        buttonCell.button.alpha = DISABLED_ALPHA
        
        let parameters = ["email": email]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/ForgotPassword",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        
        // Authentication
        let token = "\(USERNAME):\(PASSWORD)".data(using: .ascii)!.base64EncodedString()
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                buttonCell.spinner.stopAnimating()
                buttonCell.button.setTitle(self.buttonTitle, for: .normal)
                buttonCell.button.isEnabled = true
                buttonCell.button.alpha = 1.0
            }
            
            guard error == nil else {
                alert.title = "Unable to Connect"
                alert.message = "Please check your internet connection."
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .ascii) ?? ""
            switch msg {
            case "internal error":
                alert.title = "Internal Error"
                alert.message = "Our server is termporarily unavailable. Please try again later."
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
            case "not found":
                alert.title = "No Matches Found"
                alert.message = "Your provided email address does not match an Eventure account. Please check that you have entered it correctly."
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
            case "success":
                alert.title = "Reset Email Sent!"
                alert.message = "Please check your inbox for instructions on how to reset your password."
                alert.addAction(.init(title: "Cool", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            default:
                alert.title = "Error"
                alert.message = "An unknown error has occurred."
                alert.addAction(.init(title: "Dismiss", style: .default, handler: nil))
            }
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        task.resume()
    }
   

}
