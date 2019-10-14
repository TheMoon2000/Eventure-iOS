//
//  RegisterTableController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RegisterTableController: UITableViewController {
    
    var loginView: LoginViewController?
    
    /// A boolean indicating whether the picker view is currently visible.
    private var showingPicker = false
    
    private var picker: UIPickerView!
    
    /// A pointer to the current signup button.
    private var signupButton: UIButton?
    
    /// An object that stores the registration information.
    private var registrationData = UserRegistrationData() {
        didSet {
            let buttonCell = self.contentCells[7] as! ButtonCell
            if registrationData.isValid {
                buttonCell.button.isEnabled = true
                buttonCell.button.alpha = 1.0
            } else {
                buttonCell.button.isEnabled = false
                buttonCell.button.alpha = DISABLED_ALPHA
            }
        }
    }
    
    /// A reference to all the pre-generated cells in the table view.
    private var contentCells = [UITableViewCell]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.canvas
        
        tableView.tintColor = AppColors.main
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        
        // Begin building content cells
        
        // 0.0 (0)
        let navCell: UITableViewCell = {
            let cell = NavBackCell()
            cell.action = {
                self.navigationController?.popViewController(animated: true)
            }
            
            return cell
        }()
        contentCells.append(navCell)
        
        // 1.0 (1)
        let titleCell: UITableViewCell = {
            let label = UILabel()
            label.text = "New Account"
            label.font = .systemFont(ofSize: 28, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = AppColors.prompt
            label.textAlignment = .center
            
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 25).isActive = true
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -22).isActive = true
            return cell
        }()
        contentCells.append(titleCell)
        
        // 1.1 (2)
        let emailCell: UITableViewCell = {
            let cell = EmailCell(parentVC: self)
            
            cell.changeHandler = { cell in
                self.verifyEmail(cell: cell, editing: true)
                self.registrationData.email = cell.email
            }
            
            cell.completionHandler = { cell in
                cell.status = .none
                self.verifyEmail(cell: cell)
            }
            
            cell.returnHandler = {
                self.contentCells[3].becomeFirstResponder()
            }
            
            return cell
        }()
        contentCells.append(emailCell)
        
        // 1.2 (3)
        let passwordCell: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Password (length ≥ 8)"
            cell.textField.textContentType = .password
            
            cell.changeHandler = { cell in
                self.verifyPassword(cell, retypeCell: self.contentCells[4] as! MinimalTextCell, editing: true)
                self.registrationData.password = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyPassword(cell, retypeCell: self.contentCells[4] as! MinimalTextCell)
            }
            cell.returnHandler = {
                self.contentCells[4].becomeFirstResponder()
            }
            
            return cell
        }()
        contentCells.append(passwordCell)
        
        // 1.3 (4)
        let repeatCell: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Re-type Password"
            cell.textField.textContentType = .password
            
            cell.changeHandler = { cell in
                self.verifyRetype(self.contentCells[3] as! MinimalTextCell, retypeCell: cell, editing: true)
                self.registrationData.retype = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyRetype(self.contentCells[3] as! MinimalTextCell, retypeCell: cell)
            }
            
            cell.returnHandler = {
                self.contentCells[5].becomeFirstResponder()
            }
            
            return cell
        }()
        contentCells.append(repeatCell)
        
        // 2.0 (5)
        let displayNameCell: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Display Name"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .words
            cell.textField.textContentType = .name
            cell.textField.returnKeyType = .done
            cell.status = .info
            
            cell.changeHandler = { cell in
                self.registrationData.displayName = cell.textField.text!
            }
            
            cell.returnHandler = {
                cell.textField.endEditing(true)
            }
            
            cell.auxiliaryView.addTarget(self, action: #selector(showDisplayNameHelp), for: .touchUpInside)
            
            return cell
        }()
        contentCells.append(displayNameCell)
        
        // 2.1 (6)
        let genderCell: UITableViewCell = {
            let cell = GenderSelectionCell()
            cell.gender = .unspecified
            return cell
        }()
        contentCells.append(genderCell)
        
        picker = {
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true
            
            picker.translatesAutoresizingMaskIntoConstraints = false
            
            return picker
        }()
        
        // 3.0 (7)
        let buttonCell: UITableViewCell = {
            let cell = ButtonCell(width: 225)
            cell.button.isEnabled = false
            cell.button.alpha = DISABLED_ALPHA
            cell.primaryAction = {
                let finishRegVC = FinishRegistration()
                finishRegVC.regVC = self
                finishRegVC.modalPresentationStyle = .fullScreen
                finishRegVC.registrationData = self.registrationData
                self.present(finishRegVC, animated: true, completion: nil)
            }
            return cell
        }()
        contentCells.append(buttonCell)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath == IndexPath(row: 2, section: 2)) {
            return showingPicker ? 216 : 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return [1, 4, 3, 1][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return contentCells[0] // Navigation cell
        case (1, 0):
            return contentCells[1] // Title
        case (1, 1):
            return contentCells[2] // Email
        case (1, 2):
            return contentCells[3] // Password
        case (1, 3):
            return contentCells[4] // Re-type password
        case (2, 0):
            return contentCells[5] // Display name
        case (2, 1):
            return contentCells[6] // Gender selection
        case (2, 2):
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            
            cell.addSubview(picker)
            
            picker.leftAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            picker.rightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            picker.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            picker.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            
            return cell
        case (3, 0):
            return contentCells[7] // Sign up button
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 2) {
            view.endEditing(true) // dismiss the keyboard
            showingPicker = !showingPicker
            
            tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .automatic)
            
            tableView.scrollToRow(at: IndexPath(row: 2, section: 2),
                                  at: .none, animated: true)
            
            UIView.animate(withDuration: 0.2) {
                tableView.contentOffset.y = max(-UIApplication.shared.statusBarFrame.height, tableView.contentOffset.y)
            }
            
            let cell = self.contentCells[6] as! GenderSelectionCell
            
            if showingPicker {
                cell.expandDisclosure()
            } else {
                cell.collapseDisclosure()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Verification helper methods
    
    /**
     Initiates email verification process on the given cell.
     
     - Parameters:
     - cell: The cell that contains the email address.
     - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyEmail(cell: EmailCell, editing: Bool = false) {
                
        if editing {
            cell.status = .none
            return
        }
        
        guard cell.email.isValidEmail() else {
            cell.status = .fail
            return
        }
        
        let parameters = ["email": cell.email]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetUserInfo",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print(error!)
                DispatchQueue.main.async { cell.status = .disconnected }
                return
            }
            
            if let str = String(data: data!, encoding: .ascii) {
                DispatchQueue.main.async {
                    cell.status = str == "not found" ? .tick : .fail
                    if str == "not found" {
                        cell.status = .tick
                        self.registrationData.emailVerified = true
                    } else {
                        cell.status = .fail
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.status = .disconnected
                }
            }
        }
        
        task.resume()
    }
    
    
    /**
     Handles the password verification process initiated by the password cell (top).
     
     - Parameters:
         - passwordCell: The cell that contains the password.
         - retypeCell: The cell that contains the retyped password.
         - editing: Whether the verification is triggered by text change.
     */
    private func verifyPassword(_ passwordCell: MinimalTextCell, retypeCell: MinimalTextCell, editing: Bool = false) {
        let password = passwordCell.textField.text!
        let retype = retypeCell.textField.text!
        
        // Situation 1: Password is valid and matches the retyped password
        if password.count >= 8 && password == retype {
            passwordCell.status = .tick
            retypeCell.status = .tick
            // Situation 2: Finished editing without satisfying situation 1
        } else if !editing {
            if password.count < 8 || !retype.isEmpty {
                passwordCell.status = .fail
                retypeCell.status = .fail
            }
            // Situation 3: The passwords don't yet match and the user is typing
        } else if retype.count >= 8 {
            passwordCell.status = retype.hasPrefix(password) ? .none : .fail
        } else {
            passwordCell.status = .none
            retypeCell.status = retype.isEmpty ? .none : .fail
        }
    }
    
    /**
     Initiates password verification for the retyped password field.
     
     - Parameters:
         - passwordCell: The cell that contains the password.
         - retypeCell: The cell that contains the retyped password.
         - editing: Whether the verification is triggered by text change.
     */
    private func verifyRetype(_ passwordCell: MinimalTextCell, retypeCell: MinimalTextCell, editing: Bool = false) {
        let password = passwordCell.textField.text!
        let retype = retypeCell.textField.text!
        
        // Situation 1: Passwords match and are valid
        if password == retype && retype.count >= 8 {
            passwordCell.status = .tick
            retypeCell.status = .tick
            // Situation 2: Finished editing without satisfying situation 1
        } else if !editing {
            passwordCell.status = .fail
            retypeCell.status = .fail
            // Situation 3: Passwords don't yet match and the user is still typing
        } else {
            passwordCell.status = password.count >= 8 && password.hasPrefix(retype)  ? .none : .fail
            retypeCell.status = passwordCell.status
        }
    }
    
    // Helper methods
    
    @objc private func showDisplayNameHelp() {
        let alert = UIAlertController(title: "Display Name", message: "This is the name that other users will see from you. It doesn't need to be unique, and it's recommended that you provide one. If you leave this field blank, your email address or your system-generated ID will be displayed instead.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension RegisterTableController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Datasource & delegate for Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ["Unspecified", "Male", "Female", "Non-binary"][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = contentCells[6] as! GenderSelectionCell
        cell.gender = [.unspecified, .male, .female, .non_binary][row]
        registrationData.gender = row - 1
    }
}
