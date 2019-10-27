//
//  InterestPreference.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class InterestPreference: UITableViewController {
    
    let choices: [User.CalendarPreference] = [.never, .alwaysAsk, .alwaysAdd]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Interested Events"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Should your interested events be automatically added to calendar?"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = AppColors.background
        cell.textLabel?.text = choices[indexPath.row].description
        cell.accessoryType = User.current!.interestPreference == choices[indexPath.row] ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        User.current?.interestPreference = choices[indexPath.row]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        User.current?.pushSettings(.preferences) { successful in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if !successful {
                internetUnavailableError(vc: self)
            }
        }
        tableView.reloadData()
    }

}
