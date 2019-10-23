//
//  MessageCenter.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageCenter: UIViewController {
    
    private var searchController: UISearchController!
    private var settingsItem: UIBarButtonItem!
    
    private var tableView: UITableView!
    
    private var loadingBG: UIView!
    private var emptyLabel: UILabel!
    
    /// Grouped and sorted notifications; latest notifications come last.
    private var groupedNotifications = [(
        AccountNotification.Sender,
        [AccountNotification]
    )]()
    
    private var touchDown = false

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
        
        tableView = {
            let tv = UITableView()
            tv.backgroundColor = AppColors.canvas
            tv.tableFooterView = UIView()
            tv.separatorInset.left = 70
            tv.delegate = self
            tv.dataSource = self
            (tv as UIScrollView).delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(oneTimeUpdate), name: NEW_NOTIFICATION, object: nil)
                
        groupNotifications()
        refreshNavBarTitle()
        updateMessages(spawnThread: true)
    }
    
    func refreshNavBarTitle() {
        if AccountNotification.unreadCount == 0 {
            navigationItem.title = "Messages"
        } else {
            navigationItem.title = "Messages (\(AccountNotification.unreadCount))"
        }
        navigationItem.backBarButtonItem = .init(title: navigationItem.title, style: .plain, target: nil, action: nil)
    }
    
    private func groupNotifications() {
        self.groupedNotifications = AccountNotification.current.sorted { g1, g2 in
            return g1.value.last!.creationDate > g2.value.last!.creationDate
        }
        
        emptyLabel.isHidden = !self.groupedNotifications.isEmpty
    }
    
    @objc private func oneTimeUpdate() {
        updateMessages()
    }
    
    private func updateMessages(spawnThread: Bool = false) {
        if touchDown {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.updateMessages()
            }
            return
        }
        AccountNotification.syncFromServer { success in
            
            self.loadingBG.isHidden = true
            
            if success {
                self.groupNotifications()
                if !self.touchDown {
                    self.tableView.reloadData()
                }
                self.refreshNavBarTitle()
            }
            
            if spawnThread {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.updateMessages(spawnThread: true)
                }
            }
        }
    }
    
    @objc private func settings() {
        let alert = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Clear Cache (Beta)", style: .destructive, handler: { _ in
            AccountNotification.cachedLogos.removeAll()
            AccountNotification.current.removeAll()
            AccountNotification.cachedNotifications.removeAll()
            AccountNotification.currentUpdateTime = .distantPast
            AccountNotification.save()
            MainTabBarController.current.addWelcomeMessage(userID: User.current!.userID)
            self.loadingBG.isHidden = false
            self.updateMessages()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.suppressNotifications = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension MessageCenter: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        touchDown = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        touchDown = false
    }
}

// MARK: - Delegate and data source
extension MessageCenter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageSenderCell()
        cell.setup(content: groupedNotifications[indexPath.row].1.last!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sender = groupedNotifications[indexPath.row].0
        sender.markAsRead()
        let messageScreen = MessageScreen(parent: self, sender: sender)
        navigationController?.pushViewController(messageScreen, animated: true)
    }
    
    
}

// MARK: - Peek and pop

extension MessageCenter: UIViewControllerPreviewingDelegate {
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {}
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let index = tableView.indexPathForRow(at: location) {
            
            previewingContext.sourceRect = tableView.rectForRow(at: index)
            let sender = groupedNotifications[index.row].0
            sender.markAsRead()
            let messageScreen = MessageScreen(parent: self, sender: sender)
            
            return messageScreen
        }
        
        return nil
    }
    
}
