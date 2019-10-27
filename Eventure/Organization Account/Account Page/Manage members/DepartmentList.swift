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
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        
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
        
        deptList = Organization.current!.departments.sorted(by: <)
        prevRow = deptList.firstIndex(of: memberProfile.department ?? "") ?? -1
    }
    

    
    @objc private func done() {
        navigationController?.popViewController(animated: true)
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
}
