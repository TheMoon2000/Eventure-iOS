//
//  DepartmentList.swift
//  Eventure
//
//  Created by jeffhe on 2019/10/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class DepartmentList: UIViewController {
    
    private var parentVC: AddMemberPage!
    private(set) var memberProfile: Membership!
    private var loadingBG: UIView!
    private var departmentTable: UITableView!
    private(set) var deptList = [String]()
    private var prevRow = -1
    
    var edited = false
    
    required init(parentVC: AddMemberPage, memberProfile: Membership) {
        super.init(nibName: nil, bundle: nil)
        
        self.memberProfile = memberProfile
        self.parentVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Departments"
        view.backgroundColor = AppColors.canvas
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addDept))
        
        departmentTable = {
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
        
        refreshDepartments()
    }
    
    private func refreshDepartments() {
        deptList = Organization.current!.departments.sorted(by: <)
        prevRow = deptList.firstIndex(of: memberProfile.department!) ?? -1
    }

    
    @objc private func addDept() {
        let alert = UIAlertController(title: "Add Department", message: "Please enter the name of the new department.", preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.autocapitalizationType = .words
            textfield.placeholder = "e.g. Marketing Team"
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Add", style: .default) { _ in
            let dept = alert.textFields![0].text!
            self.loadingBG.isHidden = false
            Organization.current?.departments.insert(dept)
            Organization.current?.pushSettings(.departments) { successful in
                self.loadingBG.isHidden = true
                if successful {
                    self.refreshDepartments()
                    self.departmentTable.reloadData()
                } else {
                    Organization.current?.roles.remove(dept)
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

extension DepartmentList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deptList.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = deptList[indexPath.row]
        cell.accessoryType = indexPath.row == prevRow ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: [0, prevRow])?.accessoryType = .none
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        memberProfile.department = deptList[indexPath.row]
        prevRow = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
            
            let alert = UIAlertController(title: "Delete department?", message: "This action cannot be undone.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
                self.attemptDeleteDept(indexPath: indexPath)
            }))
            self.present(alert, animated: true)
        })

        action.backgroundColor = AppColors.fatal
        return [action]
    }
    
    func attemptDeleteDept(indexPath: IndexPath) {
        let dept = deptList[indexPath.row]
        if (Organization.current!.members.filter { $0.department == dept }).isEmpty {
            loadingBG.isHidden = false
            Organization.current?.departments.remove(dept)
            Organization.current?.pushSettings(.departments) { successful in
                self.loadingBG.isHidden = true
                if successful {
                    self.refreshDepartments()
                    if self.memberProfile.department == dept {
                        self.memberProfile.role = ""
                    }
                    self.departmentTable.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    Organization.current?.departments.insert(dept)
                }
            }
        } else {
            let alert = UIAlertController(title: "Cannot delete row", message: "This department is already assigned to at least one member in your organization. To remove it, please first change those members to other departments.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
