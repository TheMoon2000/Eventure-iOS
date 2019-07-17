//
//  RegisterTableController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RegisterTableController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var loginView: LoginViewController?
    
    /// A boolean indicating whether the picker view is currently visible.
    private var showingPicker = false
    
    /// A pointer to the current picker view.
    private var currentPicker: UIPickerView?
    
    /// A pointer to the current signup button.
    private var signupButton: UIButton?
    
    /// Stores the raw inputs from the user.
    private(set) var userInputs = [String : String]()
    
    /// A dictionary that stores the validity status of the email and password fields (the icons).
    private var validity = [String : MinimalTextCell.StatusIcon]() {
        didSet {
            if canSignUp {
                signupButton?.alpha = 1.0
                signupButton?.isEnabled = true
            } else {
                signupButton?.alpha = DISABLED_ALPHA
                signupButton?.isEnabled = false
            }
        }
    }
    
    /// A computed variable that indicates whether the signup button should be lit up.
    private var canSignUp: Bool {
        return (validity["email"] ?? .none) == .tick && (validity["password"] ?? .none) == .tick && (validity["repeat"] ?? .none) == .tick
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        tableView.tintColor = MAIN_TINT
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.showsHorizontalScrollIndicator = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .init(x: 0, y: 0, width: 0, height: [0, 70, 20, 0][section]))
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
            let cell = NavBackCell()
            cell.action = {
                self.loginView?.navBar?.popViewController(animated: true)
            }
            
            return cell
        case (1, 0):
            let label = UILabel()
            label.text = "Register"
            label.font = .systemFont(ofSize: 28, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .darkGray
            label.textAlignment = .center
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30).isActive = true
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -22).isActive = true
            return cell
            
        case (1, 1):
            let cell = MinimalTextCell()
            cell.textField.text = userInputs["email"]
            cell.status = validity["email"] ?? .none
            cell.textField.placeholder = "Email Address"
            cell.textField.keyboardType = .emailAddress
            cell.textField.autocorrectionType = .no
            cell.completionHandler = {
                cell.status = .loading
                self.verifyEmail(cell: cell)
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? MinimalTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                self.verifyEmail(cell: cell, editing: true)
            }
            
            return cell
        case (1, 2):
            let cell = MinimalTextCell()
            cell.textField.text = userInputs["password"]
            cell.status = validity["password"] ?? .none
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Password"
            cell.textField.textContentType = .init(rawValue: "")
            cell.completionHandler = {
                self.verifyPassword(cell: cell)
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as? MinimalTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                self.verifyPassword(cell: cell, editing: true)
            }
            
            return cell
        case (1, 3):
            let cell = MinimalTextCell()
            cell.status = validity["repeat"] ?? .none
            cell.textField.text = userInputs["repeat"]
            cell.textField.isSecureTextEntry = true
            cell.textField.placeholder = "Re-type Password"
            cell.textField.textContentType = .init(rawValue: "")
            cell.completionHandler = {
                if let lastCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? MinimalTextCell {
                    self.verifyPasswords(cell: lastCell, cell2: cell)
                }
            }
            cell.returnHandler = {
                if let nextCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? MinimalTextCell {
                    nextCell.textField.becomeFirstResponder()
                }
            }
            cell.changeHandler = {
                if let lastCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? MinimalTextCell {
                    self.verifyPasswords(cell: lastCell,
                                         cell2: cell,
                                         editing: true)
                }
            }
            
            return cell
        case (2, 0):
            let cell = MinimalTextCell()
            cell.textField.text = userInputs["displayedName"]
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
            
            cell.auxiliaryView.addTarget(self, action: #selector(showDisplayNameHelp), for: .touchUpInside)
            
            return cell
        case (2, 1):
            let cell = GenderSelectionCell()
            let index = Int(userInputs["gender"] ?? "-1")!
            cell.gender = GenderSelectionCell.Gender(rawValue: index + 1)!
            userInputs["gender"] = String(index)
            return cell
        case (2, 2):
            let cell = UITableViewCell()
            let picker = UIPickerView()
            picker.dataSource = self
            picker.delegate = self
            picker.showsSelectionIndicator = true
            self.currentPicker = picker
            
            picker.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(picker)
            
            picker.centerXAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.centerXAnchor).isActive = true
            picker.centerYAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.centerYAnchor).isActive = true
            picker.heightAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.heightAnchor).isActive = true
//            picker.topAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.topAnchor).isActive = true
//            picker.bottomAnchor.constraint(equalTo: cell.safeAreaLayoutGuide.bottomAnchor).isActive = true
            picker.widthAnchor.constraint(equalTo: cell.widthAnchor,
                                          constant: -80).isActive = true
            
            return cell
        case (3, 0):
            let cell = ButtonCell(width: 225)
            signupButton = cell.button
            cell.button.isEnabled = canSignUp
            cell.button.alpha = canSignUp ? 1.0 : DISABLED_ALPHA
            cell.altButton.isHidden = true
            cell.primaryAction = {
                let finishRegVC = FinishRegistration()
                finishRegVC.regVC = self
                finishRegVC.userInputs = self.userInputs
                self.present(finishRegVC, animated: true, completion: nil)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if indexPath == IndexPath(row: 1, section: 2) {
            view.endEditing(true) // dismiss the keyboard
            showingPicker = !showingPicker
            
            tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .fade)

            tableView.scrollToRow(at: IndexPath(row: 2, section: 2),
                                  at: .none, animated: true)
            UIView.animate(withDuration: 0.2) {
                tableView.contentOffset.y = max(-UIApplication.shared.statusBarFrame.height, tableView.contentOffset.y)
            }
            
            let cell = tableView.cellForRow(at: indexPath) as! GenderSelectionCell
            
            if showingPicker {
                let row = userInputs["gender"] ?? "-1"
                currentPicker?.selectRow(Int(row)! + 1, inComponent: 0,
                                         animated: false)
                cell.expandDisclosure()
            } else {
                cell.collapseDisclosure()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // Verification helper methods
    
    /**
     Initiates email verification process on the given cell.
     
     - Parameters:
     - cell: The cell that contains the email address.
     - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyEmail(cell: MinimalTextCell, editing: Bool = false) {
        
        self.userInputs["email"] = cell.textField.text
        
        if editing {
            cell.status = .none
            validity["email"] = .none
            return
        }
        
        func isValidEmail(_ candidate: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
        }
        
        guard cell.textField.text!.isValidEmail() else {
            cell.status = .fail
            validity["email"] = .fail
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
                        self.validity["email"] = .tick
                    } else {
                        cell.status = .fail
                        self.validity["email"] = .fail
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.status = .disconnected
                    self.validity["email"] = .disconnected
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
    
    private func verifyPassword(cell: MinimalTextCell, editing: Bool = false) {
        self.userInputs["password"] = cell.textField.text
        if cell.textField.text!.count >= 8 {
            let nextCell = tableView.cellForRow(at: IndexPath(row: 3, section: 1)) as! MinimalTextCell
            
            if nextCell.textField.text == cell.textField.text {
                cell.status = .tick
                nextCell.status = .tick
                validity["password"] = .tick
                validity["repeat"] = .tick
            } else if editing {
                cell.status = .none
                validity["password"] = .none
            } else if !nextCell.textField.text!.isEmpty {
                cell.status = .fail
                nextCell.status = .fail
                validity["password"] = .fail
                validity["repeat"] = .fail
            }
        } else {
            cell.status = editing ? .none : .fail
            validity["password"] = cell.status
        }
    }
    
    /**
     Initiates verification process on the password repeat cell.
     
     - Parameters:
     - cell: The cell that contains the password.
     - cell2: The cell that contains the repeated password.
     - editing: Whether the verification is triggered by text change instead of end editing. Default is `false`.
     */
    
    private func verifyPasswords(cell: MinimalTextCell, cell2: MinimalTextCell, editing: Bool = false) {
        
        
        let pass = cell.textField.text ?? ""
        let pass2 = cell2.textField.text ?? ""
        
        userInputs["password"] = pass
        userInputs["repeat"] = pass2
        
        if (pass != pass2 || pass.count < 8) {
            if !editing {
                cell.status = .fail
                cell2.status = .fail
                validity["password"] = .fail
                validity["repeat"] = .fail
            } else if pass != pass2 {
                cell.status = .none
                cell2.status = .none
                validity["password"] = .none
                validity["repeat"] = .none
            } else {
                cell2.status = .fail
                validity["repeat"] = .fail
            }
        } else {
            cell.status = .tick
            cell2.status = .tick
            validity["password"] = .tick
            validity["repeat"] = .tick
        }
    }
    
    // Helper methods
    
    @objc private func showDisplayNameHelp() {
        let alert = UIAlertController(title: "Display Name", message: "This is the name that other users will see from you. It doesn't need to be unique. If you leave this field blank, your email address will be used instead.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as! GenderSelectionCell
        cell.gender = GenderSelectionCell.Gender(rawValue: row) ?? .unspecified
        userInputs["gender"] = String(row - 1)
    }

}
