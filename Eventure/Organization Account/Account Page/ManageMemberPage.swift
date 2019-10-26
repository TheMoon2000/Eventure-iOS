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

class ManageMemberPage: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    var parentVC: OrgAccountPageController?
    
    
    private let NODEPART = "__OTHERS__"
    private var sortedMembers: [Membership]!
    private var allMembers: [Membership] {
        return Organization.current!.members
    }
    private var allDepartments: [String]!
    private var memberDictionaryList = Set<Membership>()
    private var membersByDepartment: [String: [Membership]] = [:]
    private var mappedMembers = [(String, [Membership])]()
    private var loadingBG: UIView!
    private var backGroundLabel: UILabel!
    private var myTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Members"
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
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
        
        groupMembers()
        
        view.backgroundColor = AppColors.canvas
        
        myTableView = UITableView(frame: .zero, style: .grouped)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = .clear
        myTableView.separatorStyle = .none
        self.view.addSubview(myTableView)
        
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        myTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        myTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        self.view.bringSubviewToFront(backGroundLabel)
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mappedMembers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mappedMembers[section].1.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//    }
    
    //section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mappedMembers[section].0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member:Membership = mappedMembers[indexPath.section].1[indexPath.row]
        
        let cell = MemberDisplayCell()
        cell.setup(member: member)
        
        //set up cell here
        
        return cell

    }
    
    func groupMembers() {
    //        if self.allMembers?.count == 0 {
    //            self.backGroundLabel.text = "No members"
    //        } else {
            
            //sort by name of all members
            self.sortedMembers = self.allMembers.sorted(by: { (member1, member2) -> Bool in
                member1.name.lowercased() < member2.name.lowercased()
            })
            
            mappedMembers.append((NODEPART, []))
            

            for member in sortedMembers {
                let department = member.department ?? NODEPART
                if membersByDepartment[department] == nil {
                    membersByDepartment[department] = [member]
                } else {
                    membersByDepartment[department]?.append(member)
                }
            }
        
        mappedMembers = membersByDepartment.map { ($0, $1) }.sorted { $0.0.lowercased() < $1.0.lowercased() }
        print(mappedMembers)
            //FIXME: potential bug
            

            }

    
    
}
