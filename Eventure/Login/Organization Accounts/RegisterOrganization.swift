//
//  RegisterOrganization.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/3.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RegisterOrganization: UITableViewController {
    
    var loginView: LoginViewController!
    
    /// An array of all the cells displayed on the organization registration page.
    private var pageCells = [UITableViewCell]()
    
    var registrationData = OrganizationRegistrationData() {
        didSet {
            let buttonCell = self.pageCells[10] as! ButtonCell
            if registrationData.isValid {
                buttonCell.button.isEnabled = true
                buttonCell.button.alpha = 1.0
            } else {
                buttonCell.button.isEnabled = false
                buttonCell.button.alpha = DISABLED_ALPHA
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = AppColors.tableBG
        tableView.tintColor = AppColors.main
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none

        // 0.0 (0)
        let titleCell: UITableViewCell = {
            let label = UILabel()
            label.text = "New Organization"
            label.font = .systemFont(ofSize: 27, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = AppColors.prompt
            label.textAlignment = .center
            
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30).isActive = true
            label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -22).isActive = true
            return cell
        }()
        pageCells.append(titleCell)
        
        // 0.1 (1)
        let displayName: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Organization Name"
            cell.textField.autocapitalizationType = .words
            cell.textField.enablesReturnKeyAutomatically = true
            cell.textField.returnKeyType = .next
            
            cell.changeHandler = { cell in
                self.verifyOrganizationName(cell: cell, editing: true)
                self.registrationData.title = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyOrganizationName(cell: cell)
            }
            
            cell.returnHandler = {
                self.pageCells[2].becomeFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(displayName)
        
        // 0.2 (2)
        let website: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Website (optional)"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.keyboardType = .URL
            cell.textField.textContentType = .URL
            cell.textField.returnKeyType = .done
            
            cell.changeHandler = { cell in
                self.verifyWebsite(cell: cell, editing: true)
                self.registrationData.website = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyWebsite(cell: cell)
            }
            
            cell.returnHandler = {
                cell.endEditing(true)
            }
            
            return cell
        }()
        pageCells.append(website)
        
        // 0.3 (3)
        let tagCell = ChooseTagCell(parentVC: self)
        tagCell.overlay.backgroundColor = AppColors.background
        pageCells.append(tagCell)
        
        // 0.4 (4)
        let imagePicker = ChooseImageCell(parentVC: self)
        imagePicker.chooseImageHandler = { image in
            self.registrationData.logo = image
        }
        pageCells.append(imagePicker)
        
        
        // 1.0 (5)
        let orgID: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Organization ID (permanent)"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .none
            cell.textField.enablesReturnKeyAutomatically = true
            cell.textField.textContentType = .username
            cell.textField.keyboardType = .asciiCapable
            cell.textField.returnKeyType = .next
            
            cell.changeHandler = { cell in
                self.registrationData.orgID = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyOrgID(cell: cell)
            }
            
            cell.returnHandler = {
                self.pageCells[6].becomeFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(orgID)
        
        // 1.1 (6)
        let password: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Password (length ≥ 8)"
            cell.textField.isSecureTextEntry = true
            cell.textField.textContentType = .password
            
            cell.changeHandler = { cell in
                self.verifyPassword(cell,
                                    retypeCell: self.pageCells[7] as! MinimalTextCell,
                                    editing: true)
                self.registrationData.password = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyPassword(cell, retypeCell: self.pageCells[7] as! MinimalTextCell)
            }
            
            cell.returnHandler = {
                self.pageCells[7].becomeFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(password)
        
        // 1.2 (7)
        let passwordRepeat: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "Re-type Password"
            cell.textField.isSecureTextEntry = true
            cell.textField.textContentType = .password
            
            cell.changeHandler = { cell in
                self.verifyRetype(self.pageCells[6] as! MinimalTextCell,
                                  retypeCell: cell,
                                  editing: true)
                self.registrationData.retype = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyRetype(self.pageCells[6] as! MinimalTextCell,
                                  retypeCell: cell)
            }
            
            cell.returnHandler = {
                self.pageCells[8].becomeFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(passwordRepeat)
        
        // 2.0 (8)
        let contactName: UITableViewCell = {
            let cell = MinimalTextCell()
            cell.textField.placeholder = "President / Contact Name"
            cell.textField.autocapitalizationType = .words
            cell.textField.autocorrectionType = .no
            cell.textField.textContentType = .name
            
            cell.changeHandler = { cell in
                self.registrationData.contactName = cell.textField.text!
            }
            
            cell.completionHandler = { cell in
                self.verifyContactName(cell)
            }
            
            cell.returnHandler = {
                self.pageCells[9].becomeFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(contactName)
        
        // 2.1 (9)
        let contactEmail: UITableViewCell = {
            let cell = EmailCell(parentVC: self)
            
            cell.changeHandler = { cell in
                self.registrationData.contactEmail = cell.email
            }
            
            cell.completionHandler = { cell in
                cell.status = cell.email.isValidEmail() ? .tick : .fail
            }
            
            cell.returnHandler = {
                let _ = cell.resignFirstResponder()
            }
            
            return cell
        }()
        pageCells.append(contactEmail)
        
        // 3.0 (10)
        let registerButtonCell: UITableViewCell = {
            let cell = ButtonCell(width: 220)
            cell.button.setTitle("Register", for: .normal)
            cell.button.isEnabled = false
            cell.button.backgroundColor = AppColors.main
            cell.button.alpha = DISABLED_ALPHA
            cell.primaryAction = {
                self.registerOrg()
            }
            return cell
        }()
        pageCells.append(registerButtonCell)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [6, 4, 3, 1][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row) {

        // Organization info
        case (0, 0):
            return pageCells[0] // Register title text
        case (0, 1):
            return pageCells[1] // Organization Title
        case (0, 2):
            return pageCells[2] // Website (optional)
        case (0, 3):
            return pageCells[3] // Tags (choose 1 - 3)
        case (0, 4):
            return pageCells[4] // Logo image (optional)
        case (0, 5):
            return SeparatorCell(top: 25, bottom: 20)
        
        // Login credentials
        case (1, 0):
            return pageCells[5] // Organization Account ID
        case (1, 1):
            return pageCells[6] // Password
        case (1, 2):
            return pageCells[7] // Password repeat
        case (1, 3):
            return SeparatorCell(top: 20, bottom: 20)
        
        // Contact
        case (2, 0):
            return pageCells[8] // Contact name
        case (2, 1):
            return pageCells[9] // Contact email
        case (2, 2):
            return SeparatorCell(top: 20, bottom: 20)
        
        // Button
        case (3, 0):
            return pageCells[10] // Register button
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genericCell = tableView.cellForRow(at: indexPath)!
        if let pickerCell = genericCell as? ChooseImageCell {
            pickerCell.chooseImage()
        } else if let tagCell = genericCell as? ChooseTagCell {
            
            let tagPicker = TagPickerView()
            tagPicker.customTitle = "Pick 1 ~ 3 tags that best describe your organization!"
            tagPicker.customSubtitle = ""
            tagPicker.maxPicks = 3
            tagPicker.customButtonTitle = "Done"
            tagPicker.customContinueMethod = { tagPicker in
                tagCell.status = .done
                self.navigationController?.popViewController(animated: true)
            }
            
            tagPicker.customDisappearHandler = { tags in
                self.registrationData.tags = tags
            }
            
            tagPicker.selectedTags = registrationData.tags

            navigationController?.pushViewController(tagPicker, animated: true)
            tableView.endEditing(true)
        }
    }
    
    @objc private func registerOrg() {
        let finishScreen = OrgFinishRegistration()
        finishScreen.regVC = self
        finishScreen.modalPresentationStyle = .fullScreen
        finishScreen.registrationData = registrationData
        
        present(finishScreen, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavbarOpacity()
    }
    
}

// MARK: - Verification methods


extension RegisterOrganization {
    
    private func verifyOrganizationName(cell: MinimalTextCell, editing: Bool = false) {
        if editing {
            cell.status = cell.textField.text!.count > 255 ? .fail : .none
        } else if !editing {
            
            // Organization ID should not be blank
            guard !CharacterSet(charactersIn: cell.textField.text!).isSubset(of: .whitespaces) else {
                cell.status = .fail
                return
            }
            
            cell.status = .tick
        }
    }
    
    /**
     Initiates verification on the website URL of the given cell.
     
     - Parameters:
         - cell: The cell that contains the website URL.
         - editing: Whether the verification process is triggered by text change.
     */
    private func verifyWebsite(cell: MinimalTextCell, editing: Bool = false) {
        let website = cell.textField.text!
        
        if website.isEmpty {
            cell.status = .none
            return
        }
        
        if editing {
            if website.count > 255 || !CharacterSet(charactersIn: website).isSubset(of: .urlPathAllowed) {
                cell.status = .fail
            } else {
                cell.status = .none
            }
        } else {
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let count = detector.numberOfMatches(in: website, options: [], range: NSMakeRange(0, website.utf16.count))
            
            cell.status = count == 1 ? .tick : .fail
        }
    }
    
    /**
     Initiates email verification on the given cell.
     
     - Parameters:
        - cell: The cell that contains the email address.
     
     - Note: Here we do not require the email to be unique, since one person may be in charge of multiple organizations.
     */
    private func verifyEmail(cell: EmailCell) {
        if cell.email.isValidEmail() {
            cell.status = .tick
        } else {
            cell.status = .fail
        }
    }
    
    /**
     Initiates organization ID verification on the given cell.
     
     - Parameters:
        - cell: The cell that contains the organization ID.
     */
    private func verifyOrgID(cell: MinimalTextCell, editing: Bool = false) {
        let id = cell.textField.text!
        
        cell.status = .loading
        
        // Organization ID should not be blank
        guard !CharacterSet(charactersIn: id).isSubset(of: .whitespaces) else {
            cell.status = .fail
            return
        }
        
        if editing {
            cell.status = id.count > 32 ? .fail : .none
            return
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: ["orgId": id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    cell.status = .disconnected
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)!
            DispatchQueue.main.async {
                if msg == "not found" {
                    cell.status = .tick
                    self.registrationData.orgIDVerified = true
                } else {
                    print(msg)
                    cell.status = .fail
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
    
    private func verifyContactName(_ cell: MinimalTextCell) {
        if !cell.textField.text!.isEmpty && cell.textField.text!.count < 255 {
            cell.status = .tick
        } else {
            cell.status = .fail
        }
    }
}

extension RegisterOrganization {
    
    func updateNavbarOpacity() {
        
        guard navigationController != nil else { return }
        
        let top = navigationController!.navigationBar.frame.minY + navigationController!.navigationBar.frame.height
        if top + tableView.contentOffset.y > 70 {
            navigationController?.navigationBar.shadowImage = nil
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationItem.title = "New Organization"
            tableView.scrollIndicatorInsets.top = 0
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationItem.title = nil
            tableView.scrollIndicatorInsets.top = -navigationController!.navigationBar.frame.height
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavbarOpacity()
    }
    
}
