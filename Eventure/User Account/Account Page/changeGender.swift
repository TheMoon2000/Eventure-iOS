//
//  changeGender.swift
//  Eventure
//
//  Created by jeffhe on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class changeGender: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    private var myTableView: UITableView!
    
    private var selected: Int = (User.current?.gender)!.rawValue
    private var new: Int = (User.current?.gender)!.rawValue
    private var newIndexPath: IndexPath = []
    
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
        self.view.addSubview(myTableView)
        //set location constraints of the tableview
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
        
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
            label.text = "Modifying..."
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if newIndexPath != indexPath {
            tableView.cellForRow(at: newIndexPath)?.accessoryType = .none
        }
        new = indexPath.row - 1
        newIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsItemCell()
        cell.accessoryType = .none
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            cell.icon.image = UIImage(named: "unknown")
            cell.titleLabel.text = "Unspecified"
        case (0,1):
            cell.icon.image = UIImage(named: "male")
            cell.titleLabel.text = "Male"
        case (0,2):
            cell.icon.image = UIImage(named: "female")
            cell.titleLabel.text = "Female"
        case (0,3):
            cell.icon.image = UIImage(named: "default_user")
            cell.titleLabel.text = "Non-Binary"
            
        default:
            break
        }
        
        if (indexPath.row == selected + 1) {
            cell.accessoryType = .checkmark
            new = indexPath.row - 1
            newIndexPath = indexPath
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " Displayed Gender"
    }
    
    @objc private func doneButtonPressed() {
        print("yes")
        if (new == selected) {
            self.navigationController?.popViewController(animated: true)
        } else {
            print("initiated")
            spinner.startAnimating()
            spinnerLabel.isHidden = false
            
            let url = URL.with(base: API_BASE_URL,
                               API_Name: "account/UpdateUserInfo",
                               parameters: [
                                "uuid": String(User.current!.uuid)
                ])!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addAuthHeader()
            let body = JSON(dictionaryLiteral: ("Gender", new))
            request.httpBody = try? body.rawData()
            
            let task = CUSTOM_SESSION.dataTask(with: request) {
                data, response, error in
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
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
                        User.current!.gender = User.Gender(rawValue: self.new)!
                    }
                }
            }
            
            task.resume()
        }
    }
    
}
