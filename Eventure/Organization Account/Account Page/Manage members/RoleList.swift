//
//  RoleList.swift
//  Eventure
//
//  Created by jeffhe on 2019/10/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RoleList: UIViewController {
    
    private var parentVC: AddMemberPage!
    private(set) var memberProfile: Membership!
    private var loadingBG: UIView!
    private var roleTable: UITableView!
    private(set) var roleList = [String]()
    private var prevRow = -1
    
    var edited = false
    
    required init(parentVC: AddMemberPage, memberProfile: Membership!) {
        super.init(nibName: nil, bundle: nil)
        
        self.memberProfile = memberProfile
        self.parentVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Roles"
        view.backgroundColor = AppColors.canvas
               
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addRole))
        
        roleTable = {
            let tb = UITableView()
            tb.backgroundColor = .clear
            tb.tintColor = AppColors.main
            tb.tableFooterView = UIView()
            tb.delegate = self
            tb.dataSource = self
            tb.contentInsetAdjustmentBehavior = .always
            tb.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tb)
            
            tb.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tb.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tb.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tb.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tb
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        refreshRoles()
    }
    
    private func refreshRoles() {
        roleList = Organization.current!.roles.sorted(by: <)
        prevRow = roleList.firstIndex(of: memberProfile.role) ?? -1
    }
    
    @objc private func addRole() {
        let alert = UIAlertController(title: "Add Role", message: "Please enter the name of the new role.", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.autocapitalizationType = .words
            textfield.placeholder = "e.g. General Member"
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Add", style: .default) { _ in
            let role = alert.textFields![0].text!
            self.loadingBG.isHidden = false
            Organization.current?.roles.insert(role)
            Organization.current?.pushSettings(.roles) { successful in
                self.loadingBG.isHidden = true
                if successful {
                    self.refreshRoles()
                    self.roleTable.reloadData()
                } else {
                    Organization.current?.roles.remove(role)
                    internetUnavailableError(vc: self)
                }
            }
        })
        present(alert, animated: true)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

extension RoleList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = roleList[indexPath.row]
        cell.accessoryType = indexPath.row == prevRow ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: [0, prevRow])?.accessoryType = .none
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        cell.backgroundColor = AppColors.background
        cell.accessoryType = .checkmark
        memberProfile.role = roleList[indexPath.row]
        prevRow = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
            
            let alert = UIAlertController(title: "Delete role?", message: "This action cannot be undone.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                self.attemptDeleteRole(indexPath: indexPath)
            }))
            self.present(alert, animated: true)
        })

        action.backgroundColor = AppColors.fatal
        return [action]
    }
    
    func attemptDeleteRole(indexPath: IndexPath) {
        let role = roleList[indexPath.row]
        if (Organization.current!.members.filter { $0.role == role }).isEmpty {
            loadingBG.isHidden = false
            Organization.current?.roles.remove(role)
            Organization.current?.pushSettings(.roles) { successful in
                self.loadingBG.isHidden = true
                if successful {
                    self.refreshRoles()
                    if self.memberProfile.role == role {
                        self.memberProfile.role = ""
                    }
                    self.roleTable.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    Organization.current?.roles.insert(role)
                }
            }
        } else {
            let alert = UIAlertController(title: "Cannot delete row", message: "This role is already assigned to at least one member in your organization. To remove this role, please first change those members to other roles.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
