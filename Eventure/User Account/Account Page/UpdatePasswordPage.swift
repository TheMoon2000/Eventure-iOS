//
//  UpdatePasswordPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class UpdatePasswordPage: UITableViewController {
    
    private(set) var passwordCell: GenericTextCell!
    private(set) var retypeCell: GenericTextCell!
    
    private var spinner: UIActivityIndicatorView!
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.canvas
        navigationItem.rightBarButtonItem = .init(title: "Update", style: .done, target: self, action: #selector(updatePassword))
        
        passwordCell = {
            let cell = GenericTextCell(title: "New Password")
            cell.inputField.isSecureTextEntry = true
            cell.inputField.textContentType = .password
            cell.inputField.returnKeyType = .next
            cell.submitAction = { textfield, spinner in
                self.retypeCell.inputField.becomeFirstResponder()
            }
            
            return cell
        }()
        
        retypeCell = {
            let cell = GenericTextCell(title: "Re-type Password")
            cell.inputField.isSecureTextEntry = true
            cell.inputField.textContentType = .password
            cell.inputField.returnKeyType = .done
            cell.submitAction = { textfield, spinner in
                textfield.resignFirstResponder()
                self.updatePassword()
            }
            
            return cell
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = AppColors.lightControl
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return spinner
        }()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if passwordCell.inputField.text!.isEmpty {
            passwordCell.inputField.becomeFirstResponder()
        }
    }
    
    @objc private func updatePassword() {
        
        let new = passwordCell.inputField.text!
        let retype = retypeCell.inputField.text!
        
        let warning = UIAlertController(title: "Cannot update password", message: nil, preferredStyle: .alert)
        
        warning.addAction(.init(title: "Dismiss", style: .cancel))
        
        // Perform a series of checks to make sure that the passwords are valid
        
        guard new == retype else {
            warning.message = "Passwords don't match."
            present(warning, animated: true, completion: nil)
            return
        }
        
        guard new.count >= 8 else {
            warning.message = "Paswords must be at least 8 characters long."
            present(warning, animated: true, completion: nil)
            return
        }
        
        // No problem occurred, proceeed
        
        spinner.startAnimating()
        passwordCell.inputField.isEnabled = false
        retypeCell.inputField.isEnabled = false
        
        let url = URL.with(
            base: API_BASE_URL,
            API_Name: "account/UpdateUserPassword",
            parameters: [
                "uuid": String(User.current!.uuid),
                "password": new
            ])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.passwordCell.inputField.isEnabled = true
                self.retypeCell.inputField.isEnabled = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)!
            
            if msg == INTERNAL_ERROR {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
                return
            } else if msg == "success" {
                User.current?.password_MD5 = new.md5()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                warning.message = msg
                DispatchQueue.main.async {
                    self.present(warning, animated: true, completion: nil)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Update Password"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return [passwordCell, retypeCell][indexPath.row]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
