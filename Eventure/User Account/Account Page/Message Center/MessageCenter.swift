//
//  MessageCenter.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageCenter: UITableViewController {
    
    private var searchController: UISearchController!
    private var settingsItem: UIBarButtonItem!
    
    private var loadingBG: UIView!
    private var emptyLabel: UILabel!
    
    /// Grouped and sorted notifications; latest notifications come last.
    private var groupedNotifications = [[AccountNotification]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.navbar
        
        let searchResults = MessageSearchResults()
        
        searchController = {
            let sc = UISearchController(searchResultsController: searchResults)
            sc.searchResultsUpdater = searchResults
            sc.searchBar.placeholder = "Search"
            sc.searchBar.tintColor = AppColors.main
            sc.dimsBackgroundDuringPresentation = true
            
            navigationItem.searchController = sc
            return sc
        }()
        
        definesPresentationContext = true
        
        settingsItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(settings))
        navigationItem.rightBarButtonItem = settingsItem
        
        tableView.backgroundColor = AppColors.canvas
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 70
        
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.text = "No messages."
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessages), name: NEW_NOTIFICATION, object: nil)
        
        groupNotifications()
        refreshNavigationBarTitle()
    }
    
    private func refreshNavigationBarTitle() {
        if AccountNotification.unreadCount == 0 {
            navigationItem.title = "Messages"
        } else {
            navigationItem.title = "Messages (\(AccountNotification.unreadCount))"
        }
    }
    
    private func groupNotifications() {
        self.groupedNotifications = AccountNotification.current.values.sorted { g1, g2 in
            return g1.last!.creationDate > g2.last!.creationDate
        }
        
        emptyLabel.isHidden = !self.groupedNotifications.isEmpty
    }
    
    @objc private func updateMessages() {
        AccountNotification.syncFromServer { success in
            if success {
                self.groupNotifications()
                self.tableView.reloadData()
                self.refreshNavigationBarTitle()
            }
        }
    }
    
    @objc private func settings() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.suppressNotifications = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}


extension MessageCenter {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageSenderCell()
        cell.setup(content: groupedNotifications[indexPath.row].last!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
