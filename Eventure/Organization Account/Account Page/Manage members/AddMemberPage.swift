//
//  AddMemberPage.swift
//  Eventure
//
//  Created by jeffhe on 2019/10/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class AddMemberPage: UITableViewController {
    
    var parentVC: AccountViewController?
    
    private var graduationCellExpanded = false
    private var saveBarButton: UIBarButtonItem!
    private var spinner: UIBarButtonItem!
    
    private var lastUpdateTime = Date()
    
    private(set) var memberProfile: Membership!
    private var backup: Membership?
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(member: Membership?) {
        super.init(nibName: nil, bundle: nil)
        
        backup = member
        memberProfile = member?.clone() ?? Membership(orgID: Organization.current!.id)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = backup == nil ? "New Member" : "Member Profile"
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        tableView.tintColor = AppColors.main
        tableView.backgroundColor = AppColors.tableBG
        
        
        saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(save))
        saveBarButton.isEnabled = true
        if backup == nil { saveBarButton.title = "Invite" }
        navigationItem.rightBarButtonItem = saveBarButton
        
        if backup == nil {
            navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: #selector(close))
        }
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.tintColor = AppColors.lightControl
            spinner.startAnimating()
            
            return UIBarButtonItem(customView: spinner)
        }()
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }

    
    @objc private func save() {
        
        guard !memberProfile.role.isEmpty else {
            let warning = UIAlertController(title: "Member must have a position!", message: "You have not specified a position for this member.", preferredStyle: .alert)
            warning.addAction(.init(title: "OK", style: .cancel))
            present(warning, animated: true)
            return
        }
        
        guard memberProfile.email.isValidEmail() else {
            let warning = UIAlertController(title: "Invalid email format!", message: "Please check that you have entered the member's email correctly.", preferredStyle: .alert)
            warning.addAction(.init(title: "OK", style: .cancel))
            present(warning, animated: true)
            return
        }
        
        guard !memberProfile.name.isEmpty else {
            let warning = UIAlertController(title: "Name cannot be empty!", message: "How can a member have no name?", preferredStyle: .alert)
            warning.addAction(.init(title: "OK", style: .cancel))
            present(warning, animated: true)
            return
        }
        
        navigationItem.rightBarButtonItem = spinner
        
        var parameters = [
            "email": memberProfile.email,
            "name": memberProfile.name,
            "orgId": memberProfile.orgID,
            "role": memberProfile.role,
            "dateJoined": DATE_FORMATTER.string(from: memberProfile.joinedDate ?? .distantPast)
        ]
        
        parameters["department"] = memberProfile.department
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/AddMember",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.saveBarButton
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                
                DispatchQueue.main.async {
                    if let backup = self.backup {
                        backup.importData(from: self.memberProfile)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        Organization.current?.members.insert(self.memberProfile)
                        self.dismiss(animated: true)
                    }
                }
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alert.addAction(.init(title: "Dismiss", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
            
        }
        task.resume()
        
    }
    
    private func getName(email: String, targetCell: GenericTextCell) {
                
        let currentDate = Date()
        lastUpdateTime = currentDate
    
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetName",
                           parameters: ["email": email])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
                        
            if self.lastUpdateTime > currentDate { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard error == nil else { return }
            
            if let name = String(data: data!, encoding: .utf8), !name.isEmpty {
                DispatchQueue.main.async {
                    self.memberProfile.name = name
                    if targetCell.inputField.text!.isEmpty {
                        targetCell.inputField.text = name
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func removeMember(_ member: Membership) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/RemoveMember",
                           parameters: ["orgId": member.orgID, "email": member.email])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                DispatchQueue.main.async {
                    Organization.current!.members.remove(self.memberProfile)
                    self.navigationController?.popViewController(animated: true)
                }
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alert.addAction(.init(title: "Dismiss", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
            
        }
        task.resume()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    

}


extension AddMemberPage {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Contact Information", "Membership Type", nil][section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return backup == nil ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2, 2, 1][section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return contentCells[indexPath.section][indexPath.row]
        
        switch indexPath {
        case [0, 0]:
            let cell = GenericTextCell(title: "Member Email")
            cell.inputField.keyboardType = .emailAddress
            cell.inputField.textContentType = .emailAddress
            cell.inputField.autocapitalizationType = .none
            cell.inputField.enablesReturnKeyAutomatically = true
            cell.inputField.text = self.memberProfile.email
            cell.inputField.returnKeyType = .next
            
            cell.changeHandler = { textfield in
                self.memberProfile.email = textfield.text!
                if let nameCell = tableView.cellForRow(at: [0, 1]) as? GenericTextCell, nameCell.inputField.text!.isEmpty {
                    self.getName(email: textfield.text!, targetCell: nameCell)
                }
            }
            
            cell.submitAction = { _, _ in
                if let nameCell = tableView.cellForRow(at: [0, 1]) as? GenericTextCell {
                    nameCell.inputField.becomeFirstResponder()
                }
            }
            
            return cell
        case [0, 1]:
            let cell = GenericTextCell(title: "Name")
            cell.inputField.placeholder = "Full Name"
            cell.inputField.textContentType = .name
            cell.inputField.autocapitalizationType = .words
            cell.inputField.enablesReturnKeyAutomatically = true
            cell.inputField.text = self.memberProfile.name
            cell.inputField.returnKeyType = .done
            
            cell.changeHandler = { textfield in
                self.memberProfile.name = textfield.text!
            }
            
            cell.submitAction = { textfield, _ in
                textfield.resignFirstResponder()
            }
            return cell
        case [1, 0]:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Department"
            cell.detailTextLabel?.text = self.memberProfile.department ?? "None"
            return cell
        case [1, 1]:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Position"
            cell.detailTextLabel?.text = memberProfile.role.isEmpty ? "None" : memberProfile.role
            cell.detailTextLabel?.numberOfLines = 2
            return cell
        case [2, 0]:
            let cell = UITableViewCell()
            cell.backgroundColor = AppColors.background
            
            let label = UILabel()
            label.textColor = AppColors.fatal
            label.text = "Remove Member"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [1, 0]:
            let dl = DepartmentList(parentVC: self, memberProfile: memberProfile)
            navigationController?.pushViewController(dl, animated: true)
        case [1, 1]:
            let rl = RoleList(parentVC: self, memberProfile: memberProfile)
            navigationController?.pushViewController(rl, animated: true)
        case [2, 0]:
            let alert = UIAlertController(title: "Remove Member?", message: "This member will no longer be part of the organization.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Remove", style: .destructive, handler: { _ in
                self.removeMember(self.memberProfile)
                Organization.current?.members.remove(self.memberProfile)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        default:
            break
        }
    }
}
