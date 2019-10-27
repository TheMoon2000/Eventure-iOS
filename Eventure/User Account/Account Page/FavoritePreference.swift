//
//  FavoritePreference.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class FavoritePreference: UITableViewController {

    let choices: [User.CalendarPreference] = [.never, .alwaysAsk, .alwaysAdd]
    private var previousChoice = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite Events"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
        previousChoice = choices.firstIndex(of: User.current!.favoritePreference) ?? -1
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        
        let title = UILabel()
        title.numberOfLines = 5
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.attributedText = "Should favorite events be automatically added to your calendar?".attributedText()
        title.textColor = AppColors.prompt
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)
        
        title.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 20).isActive = true
        title.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -20).isActive = true
        title.topAnchor.constraint(equalTo: header.topAnchor, constant: 20).isActive = true
        title.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20).isActive = true
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = AppColors.background
        cell.textLabel?.text = choices[indexPath.row].description
        cell.accessoryType = User.current!.favoritePreference == choices[indexPath.row] ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        User.current?.favoritePreference = choices[indexPath.row]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        User.current?.pushSettings(.preferences) { successful in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if !successful {
                internetUnavailableError(vc: self)
            }
        }
        
        if previousChoice != indexPath.row {
            UISelectionFeedbackGenerator().selectionChanged()
            tableView.cellForRow(at: [0, previousChoice])?.accessoryType = .none
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            previousChoice = indexPath.row
        }
    }

    
}
