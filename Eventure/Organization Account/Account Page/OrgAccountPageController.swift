//
//  OrgAccountPageController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class OrgAccountPageController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Dashboard"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SettingsItemCell.classForCoder(), forCellReuseIdentifier: "item")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = UITableViewCell()
            cell.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            let label = UILabel()
            label.text = "Log Out"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        default:
            break
        }

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let alert = UIAlertController(title: "Do you want to log out?", message: "Changes you've made have been saved.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
                Organization.current = nil
                MainTabBarController.current.openScreen()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        default:
            break
        }
    }
    
}
