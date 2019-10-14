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
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.canvas
        title = "Organization Info"
        
        myTableView = UITableView()
        myTableView.contentInset.top = 10
        myTableView.register(OrgSettingInfoCell.classForCoder(), forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = .clear
        self.view.addSubview(myTableView)
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //make sure table view appears limited
        self.myTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Verifying password..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()

    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myTableView.reloadData()
    }
    
    
    // MARK: - Table view setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as! OrgSettingInfoCell
        
        cell.setup(sectionNum: indexPath.section, rowNum: indexPath.row, type: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 { //if the user tries to change the name
            self.pushToModifyPage(type: .title)
        } else if indexPath.row == 1 { //if the user tries to change the password
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
        } else if indexPath.row == 2 {
            pushToModifyPage(type: .contactEmail)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func pushToModifyPage(type: Types) {
        let modifyAccount: GenericOneFieldPage
        if type == .title {
            modifyAccount = GenericOneFieldPage(fieldName: "Title", fieldDefault: Organization.current!.title)
        } else {
            modifyAccount = .init(fieldName: "Organization Contact Address", fieldDefault: Organization.current!.contactEmail)
        }
        
        modifyAccount.submitAction = { inputField, spinner in
            
            inputField.isEnabled = false
            spinner.startAnimating()
            
            let url = URL.with(base: API_BASE_URL,
                               API_Name: "account/UpdateOrgInfo",
                               parameters: [
                                "id": Organization.current!.id
                ])!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addAuthHeader()
            let body = JSON(dictionaryLiteral: (type.rawValue, inputField.text!))
            request.httpBody = try? body.rawData()
            
            let task = CUSTOM_SESSION.dataTask(with: request) {
                data, response, error in
                
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    inputField.isEnabled = true
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
                } else {
                    DispatchQueue.main.async {
                        if type == .title {
                            Organization.current?.title = inputField.text!
                        } else if type == .contactEmail {
                            Organization.current!.contactEmail = inputField.text!
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            task.resume()
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



