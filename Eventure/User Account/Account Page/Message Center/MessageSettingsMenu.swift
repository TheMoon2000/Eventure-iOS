//
//  MessageSettingsMenu.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageSettingsMenu: UITableViewController {
    
    private var parentVC: MessageCenter!
    
    required init(parent: MessageCenter) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parent
        self.title = "Preferences"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.sectionFooterHeight = 5
        tableView.register(BasicSwitchCell.classForCoder(), forCellReuseIdentifier: "switch")
        view.backgroundColor = AppColors.tableBG
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [5, 2][section]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Receive messages about", nil][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! BasicSwitchCell
        
        precondition(User.current != nil, "User cannot be null!")
        let settings = User.current!.enabledNotifications
        
        switch indexPath {
        case [0, 0]:
            cell.titleLabel.text = "New Events"
            cell.switch.isOn = settings.contains(.newEvents)
        case [0, 1]:
            cell.titleLabel.text = "Event Updates"
            cell.switch.isOn = settings.contains(.eventUpdates)
        case [0, 2]:
            cell.titleLabel.text = "Membership Invitations"
            cell.switch.isOn = settings.contains(.membershipInvites)
        case [0, 3]:
            cell.titleLabel.text = "New Tickets"
            cell.switch.isOn = settings.contains(.newTickets)
        case [0, 4]:
            cell.titleLabel.text = "Others"
            cell.switch.isOn = settings.contains(.others)
        case [1, 0]:
            let cell = UITableViewCell()
            cell.backgroundColor = AppColors.background
            let c = cell.heightAnchor.constraint(equalToConstant: 50)
            c.priority = .defaultHigh
            c.isActive = true
            
            let label = UILabel()
            label.textColor = AppColors.fatal
            label.text = "Clear Cache"
            label.font = .appFontRegular(17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        case [1, 1]:
            let cell = UITableViewCell()
            cell.backgroundColor = AppColors.background
            let c = cell.heightAnchor.constraint(equalToConstant: 50)
            c.priority = .defaultHigh
            c.isActive = true
            
            let label = UILabel()
            label.textColor = AppColors.fatal
            label.text = "Clear All Messages"
            label.font = .appFontRegular(17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            
            return cell
        default:
            break
        }
        
        cell.switchHandler = { _ in
            let toggled: User.EnabledNotifications = [.newEvents, .eventUpdates, .membershipInvites, .newTickets, .others][indexPath.row]
            User.current?.enabledNotifications.formSymmetricDifference(toggled)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            User.current?.pushSettings(.preferences) { success in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if !success {
                    internetUnavailableError(vc: self)
                }
           }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == [1, 0] {
            let alert = UIAlertController(title: "Clear cache?", message: "All images will be cleared. All textual messages will be preserved.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Clear Cache", style: .destructive, handler: { _ in
                AccountNotification.cachedLogos.removeAll()
                // AccountNotification.current.removeAll()
                // AccountNotification.currentUpdateTime = .distantPast
                AccountNotification.save()
                self.parentVC.loadingBG.isHidden = false
                self.parentVC.groupNotifications()
                self.parentVC.tableView.reloadData()
                self.parentVC.updateMessages()
            }))
            
            present(alert, animated: true, completion: nil)
        } else if indexPath == [1, 1] {
            let alert = UIAlertController(title: "Clear messages?", message: "All cached messages will be erased. New data will be synced from the server.", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Clear Messages", style: .destructive, handler: { _ in
                AccountNotification.current.removeAll()
                AccountNotification.currentUpdateTime = .distantPast
                AccountNotification.save()
                self.parentVC.loadingBG.isHidden = false
                self.parentVC.groupNotifications()
                self.parentVC.tableView.reloadData()
                self.parentVC.updateMessages()
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
