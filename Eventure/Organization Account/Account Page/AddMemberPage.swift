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



class AddMemberPage: UITableViewController,EditableInfoProvider {
    
    var parentVC: AccountViewController?
    
    private var graduationCellExpanded = false
    private var contentCells = [[UITableViewCell]]()
    
    
    private var saveBarButton: UIBarButtonItem!
    private var spinner: UIActivityIndicatorView!
    
    private(set) var memberProfile: Membership!
    private var newMember = true
    
    var cellsEditable: Bool { return true }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(member: Membership?) {
        super.init(nibName: nil, bundle: nil)
        self.newMember = member == nil
        self.memberProfile = member ?? Membership(orgID: Organization.current!.id)
        if self.newMember {
            self.memberProfile.department = "None"
            self.memberProfile.role = "None"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.newMember {
            title = "New Member"
        } else {
            title = "\(self.memberProfile.name)'s Profile"
        }
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 10
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.tintColor = AppColors.main
    
        view.backgroundColor = AppColors.canvas
        
        let section0: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let nameCell = TextFieldCell(parentVC: self)
            nameCell.icon.image = #imageLiteral(resourceName: "name")
            nameCell.textfield.placeholder = "Full Name"
            nameCell.textfield.textContentType = .name
            nameCell.textfield.autocapitalizationType = .words
            nameCell.textfield.enablesReturnKeyAutomatically = true
            if !self.newMember {
                nameCell.textfield.text = self.memberProfile.name
            }
            nameCell.textfield.returnKeyType = .done
            
            nameCell.returnHandler = { textfield in
                textfield.resignFirstResponder()
            }
            
            section.append(nameCell)
            
        
            let emailCell = TextFieldCell(parentVC: self)
            emailCell.icon.image = UIImage(named: "email")
            emailCell.textfield.placeholder = "Email Address"
            emailCell.textfield.textContentType = .name
            emailCell.textfield.autocapitalizationType = .words
            emailCell.textfield.enablesReturnKeyAutomatically = true
            if !self.newMember {
                emailCell.textfield.text = self.memberProfile.email
                emailCell.textfield.isUserInteractionEnabled = false
            }
            emailCell.textfield.returnKeyType = .done
            
            emailCell.returnHandler = { textfield in
                textfield.resignFirstResponder()
            }
            
            section.append(emailCell)
            
            return section
        }()
        
        let section1: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let departmentCell = SettingsItemCell(withAccessory: true)
            departmentCell.icon.image = UIImage(named: "profile")
            departmentCell.titleLabel.text = "Department"
            departmentCell.valueLabel.numberOfLines = 1
            departmentCell.valueLabel.text = "\(self.memberProfile.department!)"
            section.append(departmentCell)
            return section
        }()
        
        let section2: [UITableViewCell] = {
            var section = [UITableViewCell]()
            let roleCell = SettingsItemCell(withAccessory: true)
            roleCell.icon.image = UIImage(named: "guest")
            roleCell.titleLabel.text = "Role"
            roleCell.valueLabel.numberOfLines = 1
            print(self.memberProfile.role)
            roleCell.valueLabel.text = "\(self.memberProfile.role)"
            section.append(roleCell)
            return section
        }()
        
        let section3: [UITableViewCell] = {
            var section = [UITableViewCell]()
            
            let cell = UITableViewCell()
            cell.backgroundColor = AppColors.background
            let c = cell.heightAnchor.constraint(equalToConstant: 50)
            c.priority = .defaultHigh
            c.isActive = true
            let label = UILabel()
            label.textColor = AppColors.badgeColor
            label.text = "Remove Member"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            section.append(cell)
            return section
        }()
        
        contentCells.append(section0)
        contentCells.append(section1)
        contentCells.append(section2)
        if !newMember {
            contentCells.append(section3)
        }
        
        if newMember {
            saveBarButton = .init(title: "Invite", style: .done, target: self, action: #selector(saveButtonPressed))
            saveBarButton.isEnabled = true
        } else {
            saveBarButton = .init(title: "Save", style: .done, target: self, action: #selector(saveButtonPressed))
            saveBarButton.isEnabled = true
        }
        
        if cellsEditable {
            navigationItem.rightBarButtonItem = saveBarButton
        }
    }

    
    @objc private func saveButtonPressed() {
        save()
    }
    
    func save(disappearing: Bool = false, _ onSuccess: (() -> ())? = nil) {
        
        if self.newMember {
            saveBarButton.title = "Inviting..."
        } else {
            saveBarButton.title = "Saving..."
        }
        saveBarButton.isEnabled = false
        
        
        var parameters = ["email": ""]
        if self.newMember {
            parameters["email"] = (contentCells[0][1] as! TextFieldCell).textfield.text
        } else {
            parameters["email"] = self.memberProfile.email
        }
        parameters["name"] = (contentCells[0][0] as! TextFieldCell).textfield.text
        parameters["orgId"] = Organization.current!.id
        parameters["role"] = self.memberProfile.role
        parameters["department"] = self.memberProfile.department
        parameters["dateJoined"] = DATE_FORMATTER.string(from: self.memberProfile.joinedDate ?? .distantPast)
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/AddMember",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
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
                    if self.newMember {
                        DispatchQueue.main.async {
                            self.memberProfile.name = (self.contentCells[0][0] as! TextFieldCell).textfield.text!
                            self.memberProfile.email = (self.contentCells[0][1] as! TextFieldCell).textfield.text!
                            Organization.current!.members.insert(self.memberProfile)
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.memberProfile.name = (self.contentCells[0][0] as! TextFieldCell).textfield.text!
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        if self.newMember {
                            self.saveBarButton.title = "Invite"
                        } else {
                            self.saveBarButton.title = "Save"
                        }
                        self.saveBarButton.isEnabled = true
                        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                        alert.addAction(.init(title: "Dismiss", style: .cancel))
                        self.present(alert, animated: true)
                    }
            }
            
        }
        task.resume()
        
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section != 0 { return nil }
        
        if !cellsEditable { return nil }
        
        let header = UIView()
        
        let title = UILabel()
        title.numberOfLines = 5
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.textColor = AppColors.prompt
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)
        
        title.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30).isActive = true
        title.topAnchor.constraint(equalTo: header.topAnchor, constant: 20).isActive = true
        title.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20).isActive = true
        
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [1,0]:
            let dl = DepartmentList(parentVC: self,memberProfile: memberProfile)
            navigationController?.pushViewController(dl, animated: true)
        case [2,0]:
            let rl = RoleList(parentVC: self,memberProfile: memberProfile)
            navigationController?.pushViewController(rl, animated: true)
        case [3,0]:
            var parameters = ["orgId" :Organization.current!.id]
            parameters["email"] = self.memberProfile.email
            
            let url = URL.with(base: API_BASE_URL,
                               API_Name: "account/RemoveMember",
                               parameters: parameters)!
            var request = URLRequest(url: url)
            request.addAuthHeader()
            
            let task = CUSTOM_SESSION.dataTask(with: request) {
                data, response, error in
                
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
        default:
            break
        }
    }
    
    private func refreshGradCell() {
        
        let chooserCell = contentCells[0][4] as! GraduationYearChooser
        chooserCell.picker.isUserInteractionEnabled = graduationCellExpanded
        
        UIView.animate(withDuration: 0.2) {
            chooserCell.picker.alpha = self.graduationCellExpanded ? 1.0 : 0.0
        }
        
        chooserCell.valueChanged(setup: true)
        
         tableView.beginUpdates()
         tableView.endUpdates()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let departmentCell = contentCells[1][0] as? SettingsItemCell {
            departmentCell.valueLabel.text = "\(self.memberProfile.department!)"
        }
        if let roleCell = contentCells[2][0] as? SettingsItemCell {
            roleCell.valueLabel.text = "\(self.memberProfile.role)"
        }
    }
    

}
