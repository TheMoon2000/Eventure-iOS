//
//  OrgInfoPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class OrgSettingInfoPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.tableBG
        title = "Organization Info"
        
        myTableView = {
            let tv = UITableView(frame: .zero, style: .grouped)
            tv.tableHeaderView = UIView(frame: .init(x: 0, y: 0, width: 0, height: 30))
            tv.dataSource = self
            tv.delegate = self
            tv.backgroundColor = .clear
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)

            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            return tv
        }()
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTableView.reloadData()
    }
    
    
    // MARK: - Table view setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsItemCell(withAccessory: true)
        
        switch indexPath {
        case [0, 0]:
            cell.titleLabel.text = "Organization Name"
            cell.valueLabel.text = Organization.current!.title
            cell.icon.image = #imageLiteral(resourceName: "name")
        case [0, 1]:
            cell.titleLabel.text = "Password"
            cell.icon.image = #imageLiteral(resourceName: "password")
        case [0, 2]:
            cell.titleLabel.text = "Contact Name"
            cell.valueLabel.text = Organization.current!.contactName
            cell.icon.image = #imageLiteral(resourceName: "default_user")
        case [0, 3]:
            cell.titleLabel.text = "Contact Email"
            cell.valueLabel.text = Organization.current!.contactEmail
            cell.icon.image = #imageLiteral(resourceName: "email")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            pushToModifyPage(type: .title)
        case [0, 1]:
            let alert = UIAlertController(title: "Verification", message: "Please enter your current password to continue.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.isSecureTextEntry = true
            })
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                let pwd = alert.textFields![0].text!
                if pwd.md5() == Organization.current!.password_MD5 {
                    let passwordSettings = UpdatePasswordPage()
                    self.navigationController?.pushViewController(passwordSettings, animated: true)
                } else {
                    let warning = UIAlertController(title: "Incorrect Password", message: nil, preferredStyle: .alert)
                    warning.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(warning, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        
        case [0, 2]:
            let modifyPage = GenericOneFieldPage(fieldName: "Contact Name", fieldDefault: Organization.current!.contactName, type: .displayedName)
            modifyPage.submitAction = { inputField, spinner in
                inputField.isEnabled = false
                spinner.startAnimating()
                
                Organization.current?.contactName = inputField.text!
                
                Organization.current?.pushSettings(.contactName) { success in
                    spinner.stopAnimating()
                    inputField.isEnabled = true
                    
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
            }
            modifyPage.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(modifyPage, animated: true)
        case [0, 3]:
            pushToModifyPage(type: .contactEmail)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    private func pushToModifyPage(type: Types, placeholder: String? = nil) {
        let modifyAccount: GenericOneFieldPage
        if type == .title {
            modifyAccount = GenericOneFieldPage(fieldName: placeholder ?? "Title", fieldDefault: Organization.current!.title)
            modifyAccount.submitAction = { inputField, spinner in
                inputField.isEnabled = false
                spinner.startAnimating()
                
                Organization.current?.title = inputField.text!
                
                Organization.current?.pushSettings(.orgTitle) { success in
                    spinner.stopAnimating()
                    inputField.isEnabled = true
                    
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
            }
        } else {
            modifyAccount = .init(fieldName: "Contact Email", fieldDefault: Organization.current!.contactEmail)
            
            modifyAccount.submitAction = { inputField, spinner in
                inputField.isEnabled = false
                spinner.startAnimating()
                
                Organization.current?.contactEmail = inputField.text!
                
                Organization.current?.pushSettings(.email) { success in
                    spinner.stopAnimating()
                    inputField.isEnabled = true
                    
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        internetUnavailableError(vc: self)
                    }
                }
            }
        }
        
        modifyAccount.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(modifyAccount, animated: true)
    }
    
}

extension OrgSettingInfoPage {
    enum Types: String {
        case title = "Title"
        case contactEmail = "Organization Contact Email"
    }
}



