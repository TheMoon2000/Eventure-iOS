//
//  CalendarPreference.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CalendarPreference: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Calendar Preferences"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.backgroundColor = AppColors.background
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = ["Interested Events", "Favorite Events"][indexPath.row]
        
        if indexPath == [0, 0] {
            cell.detailTextLabel?.text = User.current!.interestPreference.description
        } else if indexPath == [0, 1] {
            cell.detailTextLabel?.text = User.current!.favoritePreference.description
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = InterestPreference()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = FavoritePreference()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

}
