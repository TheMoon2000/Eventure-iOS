//
//  UpdateOrgCategories.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/7/7.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class UpdateOrgCategories: UITableViewController {
    
    private var loadingBG: UIView!
    private var centerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Organization Categories"

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
        
        loadingBG = view.addLoader()
        centerLabel = view.addCenteredLabel()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = AppColors.lightControl
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        if LocalStorage.categories == nil {
            reloadCategories()
        }
    }
    
    @objc private func pullToRefresh() {
        reloadCategories(pulled: true)
    }
    
    private func reloadCategories(pulled: Bool = false) {
        NetworkStatus.addTask()
        
        if pulled {
            tableView.refreshControl?.beginRefreshing()
        } else {
            loadingBG.isHidden = false
        }
        
        LocalStorage.updateOrgCategories { status in
            NetworkStatus.removeTask()
            self.tableView.refreshControl?.endRefreshing()
            self.loadingBG.isHidden = true
            
            if status == 0 {
                self.tableView.reloadData()
            } else if status == -1 {
                internetUnavailableError(vc: self)
            } else if status == -2 {
                serverMaintenanceError(vc: self)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocalStorage.categories?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let category = LocalStorage.categories![indexPath.row]
        cell.textLabel?.font = .appFontRegular(17)
        cell.textLabel?.text = category.name
        cell.textLabel?.numberOfLines = 3
        cell.accessoryType = Organization.current!.categories.contains(category) ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        guard let category = LocalStorage.categories?[indexPath.row] else {
            print("WARNING: category count and settings row count mismatch!")
            return
        }
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            Organization.current?.categories.remove(category)
        } else {
            cell.accessoryType = .checkmark
            Organization.current?.categories.insert(category)
        }
    }

}
