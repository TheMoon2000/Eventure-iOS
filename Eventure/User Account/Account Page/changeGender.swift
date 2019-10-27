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
    
    private var doneButton: UIBarButtonItem!
    private var spinner: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = AppColors.tableBG
        
        myTableView = UITableView(frame: .zero, style: .grouped)
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
        
        doneButton = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.color = AppColors.control
            spinner.startAnimating()
            spinner.hidesWhenStopped = true
            
            return UIBarButtonItem(customView: spinner)
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
            cell.icon.image = #imageLiteral(resourceName: "non-binary")
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
        return "Displayed Gender"
    }
    
    @objc private func doneButtonPressed() {
        if (new == selected) {
            self.navigationController?.popViewController(animated: true)
        } else {
            navigationItem.rightBarButtonItem = spinner
            User.current?.gender = User.Gender(rawValue: self.new)!
            
            User.current?.pushSettings(.gender) { success in
                self.navigationItem.rightBarButtonItem = self.doneButton
                
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    internetUnavailableError(vc: self)
                }
            }
        }
    }
    
}
