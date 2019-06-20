//
//  RegisterController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/18.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RegisterController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// A boolean indicating whether the picker view is currently visible.
    private var showingPicker = false
    
    ///
    private var currentPicker: UIPickerView?
    
    /// A pointer to the top right `Sign Up` bar button
    private var signupButton: UIBarButtonItem?
    
    ///
    private(set) var userInputs = [String: String]() {
        didSet {
            var valid = true
            for item in ["email", "password", "gender"] {
                valid = valid && userInputs.keys.contains(item)
            }
            signupButton?.isEnabled = valid
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // We want a grouped table view for better clarity to the user
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        
        tableView.contentInset.top = 10.0
        
        self.title = "Register Account"
        view.backgroundColor = UIColor(white: 0.97, alpha: 1) // REPLACE
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = cancel
        signupButton = UIBarButtonItem(title: "Sign Up", style: .done, target: self, action: #selector(signup))
        signupButton?.isEnabled = false
        self.navigationItem.rightBarButtonItem = signupButton
        self.navigationController?.navigationBar.tintColor = MAIN_TINT_DARK
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func signup(_ sender: UIBarButtonItem) {
        let finishRegVC = FinishRegistration()
        finishRegVC.regVC = self
        finishRegVC.userInputs = userInputs
        self.present(finishRegVC, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [3, 3][section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Login Credentials", "Profile"][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ["Password must be at least 8 characters long.", "Information in this section will be visible to other users."][section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 2) {
            return showingPicker ? 216 : 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = EditableTextCell()
            cell.textField.placeholder = "Email Address"
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocorrectionType = .no
            cell.completionHandler = {
                cell.status = .loading
                self.verifyEmail(cell: cell)
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditableTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                self.verifyEmail(cell: cell, editing: true)
            }
            
            return cell
        case (0, 1):
            let cell = EditableTextCell()
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Password"
            cell.completionHandler = {
                self.verifyPassword(cell: cell)
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? EditableTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                self.verifyPassword(cell: cell, editing: true)
            }
            
            return cell
        case (0, 2):
            let cell = EditableTextCell()
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Repeat Password"
            cell.completionHandler = {
                if let lastCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditableTextCell {
                    self.verifyPasswords(cell: lastCell, cell2: cell)
                }
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? EditableTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                if let lastCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditableTextCell {
                    self.verifyPasswords(cell: lastCell,
                                         cell2: cell,
                                         editing: true)
                }
            }
            
            return cell
        case (1, 0):
            let cell = EditableTextCell()
            cell.textField.placeholder = "Display Name"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .words
            cell.textField.returnKeyType = .done
            cell.status = .info
            cell.returnHandler = {
                cell.textField.endEditing(true)
            }
            cell.changeHandler = {
                self.userInputs["displayedName"] = cell.textField.text!.isEmpty ? nil : cell.textField.text!
            }
            
            return cell
        case (1, 1):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "Gender"
            cell.detailTextLabel?.text = "Unspecified"
            userInputs["gender"] = "-1"
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case (1, 2):
            let cell = UITableViewCell()
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true
            self.currentPicker = picker
            
            picker.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(picker)
            
            picker.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            picker.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            picker.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
            picker.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
            
            return cell
        default:
            return UITableViewCell()
        }
    }
 
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            let alert = UIAlertController(title: "Display Name", message: "This is the name that other users will see from you. It doesn't need to be unique. If you leave this field blank, your email address will be used instead.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 1 {
            view.endEditing(true) // dismiss the keyboard
            showingPicker = !showingPicker
            
            UIView.animate(withDuration: 0.25) {
                tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .fade)
            }
            
            if showingPicker {
                let row = userInputs["gender"] ?? "-1"
                currentPicker?.selectRow(Int(row)! + 1, inComponent: 0,
                                         animated: false)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /**
     Initiates email verification process on the given cell.
     
     - Parameters:
        - cell: The cell that contains the email address.
        - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyEmail(cell: EditableTextCell, editing: Bool = false) {
        
        self.userInputs["email"] = nil
        
        if editing {
            cell.status = .none
            return
        }

        func isValidEmail(_ string: String) -> Bool {
            // here, `try!` will always succeed because the pattern is valid
            let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
            return regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) != nil
        }
        
        guard isValidEmail(cell.textField.text!) else {
            cell.status = editing ? .none : .fail
            return
        }

        let parameters = ["email": cell.textField.text ?? ""]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetUserInfo",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        
        // Authentication
        let token = "\(USERNAME):\(PASSWORD)".data(using: .ascii)!.base64EncodedString()
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        
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
                        self.userInputs["email"] = cell.textField.text!
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
     Initiates password verification process on the first password cell.
     
     - Parameters:
        - cell: The cell that contains the password (NOT the repeat).
        - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyPassword(cell: EditableTextCell, editing: Bool = false) {
        self.userInputs["password"] = nil
        if cell.textField.text!.count >= 8 {
            let nextCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! EditableTextCell
            
            if nextCell.textField.text == cell.textField.text {
                cell.status = .tick
                nextCell.status = .tick
                self.userInputs["password"] = cell.textField.text
            } else if editing {
                cell.status = .none
            } else if !nextCell.textField.text!.isEmpty {
                cell.status = .fail
                nextCell.status = .fail
            }
        } else {
            cell.status = editing ? .none : .fail
        }
    }
    
    /**
     Initiates verification process on the password repeat cell.
     
     - Parameters:
        - cell: The cell that contains the password.
        - cell2: The cell that contains the repeated password.
        - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyPasswords(cell: EditableTextCell, cell2: EditableTextCell, editing: Bool = false) {
        let pass = cell.textField.text ?? ""
        let pass2 = cell2.textField.text ?? ""
        
        if (pass != pass2 || pass.count < 8) {
            if !editing {
                cell.status = .fail
                cell2.status = .fail
            } else if pass != pass2 {
                cell.status = .none
                cell2.status = .none
            } else {
                cell2.status = .fail
            }
            userInputs["password"] = nil
        } else {
            cell.status = .tick
            cell2.status = .tick
            userInputs["password"] = pass
        }
    }
    
    
    // Datasource for Picker View
    
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
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
        cell?.detailTextLabel?.text = ["Unspecified", "Male", "Female", "Non-binary"][row]
        userInputs["gender"] = String(row - 1)
    }
    


}
