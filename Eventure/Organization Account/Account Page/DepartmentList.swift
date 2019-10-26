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
    private(set) var roleList = [String]()
    private var prevIndexPath = IndexPath(row: 0, section: 0)
    
    var edited = false
    
    required init(parentVC: AddMemberPage, memberProfile: Membership!) {
        super.init(nibName: nil, bundle: nil)
        self.memberProfile = memberProfile
        self.parentVC = parentVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Departments"
        view.backgroundColor = AppColors.canvas
       
        definesPresentationContext = true
        
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        
        departmentTable = {
            let tb = UITableView()
            tb.backgroundColor = .clear
            tb.tintColor = AppColors.main
            tb.tableFooterView = UIView()
            tb.delegate = self
            tb.dataSource = self
            tb.contentInsetAdjustmentBehavior = .always
            tb.register(DepartmentCell.classForCoder(), forCellReuseIdentifier: "department")
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
        
        roleList = Organization.current!.departments.sorted(by: <)
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
        return roleList.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "department") as! DepartmentCell
      
        let depName = roleList[indexPath.row]
        
        cell.titleLabel.text = depName
        cell.isChecked = (memberProfile.department! == cell.titleLabel.text!)
        if cell.isChecked == true {
            self.prevIndexPath = indexPath
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prevCell = tableView.cellForRow(at: prevIndexPath) as! DepartmentCell
        prevCell.isChecked = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! DepartmentCell
        cell.isChecked = true
        memberProfile.department = cell.titleLabel.text!
        prevIndexPath = indexPath
    }
}
