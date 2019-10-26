//
//  ManageMemberPage.swift
//  Eventure
//
//  Created by Prince Wang on 2019/10/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ManageMemberPage: UIViewController {

    var parentVC: OrgAccountPageController?
    

    
    // UI elements
    private var loadingBG: UIView!
    private var backGroundLabel: UILabel!
    private var myTableView: UITableView!
    private var refreshControl = UIRefreshControl()
    private var saveBarButton: UIBarButtonItem!
    
    // Data
    private let NO_DEPART = "__OTHERS__"
    private var sortedMembers: [Membership]!
    private var allMembers: Set<Membership> { return Organization.current!.members }
    private var allDepartments: [String]!
    private var memberDictionaryList = Set<Membership>()
    private var mappedMembers = [(String, [Membership])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Members"
        view.backgroundColor = AppColors.canvas
        
        refreshControl.addTarget(self, action: #selector(reloadMembers), for: .valueChanged)
        refreshControl.tintColor = AppColors.lightControl
        
        saveBarButton = .init(title: "Invite", style: .done, target: self, action:  #selector(inviteButtonPressed)) //FIXME: add action
        navigationItem.rightBarButtonItem = saveBarButton
                
        myTableView = {
            let tv = UITableView(frame: .zero, style: .grouped)
            tv.dataSource = self
            tv.delegate = self
            tv.backgroundColor = .clear
            tv.separatorStyle = .none
            tv.addSubview(refreshControl)
            self.view.addSubview(tv)
            
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            return tv
        }()
        
        backGroundLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        groupMembers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        groupMembers()
        self.myTableView.reloadData()
    }
    
    @objc private func inviteButtonPressed() {
        let addPage = AddMemberPage(member: nil)
        addPage.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addPage, animated: true)
    }
    
    func groupMembers() {
        
        mappedMembers.removeAll()
        var membersByDepartment = [String: [Membership]]()
        
        // Sort by name of all members
        self.sortedMembers = self.allMembers.sorted(by: { (member1, member2) -> Bool in
            member1.name.lowercased() < member2.name.lowercased()
        })
        
        mappedMembers.append((NO_DEPART, []))

        for member in sortedMembers {
            let department = member.department ?? NO_DEPART
            if membersByDepartment[department] == nil {
                membersByDepartment[department] = [member]
            } else {
                membersByDepartment[department]?.append(member)
            }
        }
    
        mappedMembers = membersByDepartment.map { ($0, $1) }.sorted { $0.0.lowercased() < $1.0.lowercased() }
        print(mappedMembers)
    
    }
    
    /// Action triggered by pull to reload.
    @objc private func reloadMembers() {
        Organization.current!.updateMembers { successful in
            self.refreshControl.endRefreshing()
            
            guard successful else {
                internetUnavailableError(vc: self)
                return
            }
            
            DispatchQueue.global(qos: .default).async {
                self.groupMembers()
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            }
        }
    }
}


// MARK: - Table view data source

extension ManageMemberPage: UITableViewDelegate, UITableViewDataSource {
           
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: MemberDisplayCell = tableView.cellForRow(at: indexPath) as! MemberDisplayCell
        let member:Membership = cell.returnMember()
           let addPage = AddMemberPage(member: member)
           addPage.hidesBottomBarWhenPushed = true
           navigationController?.pushViewController(addPage, animated: true)
   }
   
   func numberOfSections(in tableView: UITableView) -> Int {
       return mappedMembers.count
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return mappedMembers[section].1.count
   }
   
   //section titles
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let currSection:(String, [Membership]) = mappedMembers[section]
    return currSection.0 + " (" + String(currSection.1.count) + ")"
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let member:Membership = mappedMembers[indexPath.section].1[indexPath.row]
       
       let cell = MemberDisplayCell()
       cell.setup(member: member)
               
       return cell

   }
}
