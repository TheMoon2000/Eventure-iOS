//
//  MessageSearchResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageSearchResults: UITableViewController {
    
    private var parentVC: MessageCenter!
    
    private var filteredSources = [AccountNotification.Sender]()
    private var filteredMessages = [(sender: AccountNotification.Sender, matches: [AccountNotification])]()
    
    private var emptyLabel: UILabel!
    
    required init(parent: MessageCenter) {
        super.init(nibName: nil, bundle: nil)
        
        parentVC = parent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.tableBG
        
        tableView.sectionFooterHeight = 1
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = false
            label.text = "No messages."
            label.font = .appFontRegular(16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let sourceEntries = filteredSources.isEmpty ? 0 : 1
        let messageEntries = filteredMessages.isEmpty ? 0 : 1
        return sourceEntries + messageEntries
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerTitle: String = {
            if filteredSources.isEmpty {
                return "Messages"
            } else if filteredMessages.isEmpty {
                return "Sources"
            } else {
                return ["Sources", "Messages"][section]
            }
        }()
        
        let container = UIView()
        
        let label = UILabel()
        label.layoutMargins.left = 10
        label.textColor = AppColors.prompt
        label.text = headerTitle
        label.font = .appFontRegular(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5).isActive = true
        
        return container
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredSources.isEmpty {
            return filteredMessages.count
        } else if filteredMessages.isEmpty {
            return filteredSources.count
        }
        
        return [filteredSources.count, filteredMessages.count][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        if !filteredSources.isEmpty && indexPath.section == 0 {
            let cell = MessageSenderIdentityCell()
            cell.setup(sender: filteredSources[indexPath.row])
            return cell
        } else {
            let cell = MessageSenderCell()
            let myMessage = filteredMessages[indexPath.row]
            cell.senderTitle.text = myMessage.sender.name
            if let logo = AccountNotification.current[myMessage.sender]?.last?.senderLogo {
                cell.senderLogo.image = logo
            }
            if myMessage.matches.count == 1 {
                cell.setup(content: myMessage.matches[0])
            } else {
                cell.setPreview(string: "\(myMessage.matches.count) related messages")
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sender: AccountNotification.Sender
        
        if !filteredSources.isEmpty && indexPath.section == 0 {
            sender = filteredSources[indexPath.row]
        } else {
            sender = filteredMessages[indexPath.row].sender
        }
                
        let messageScreen = MessageScreen(parent: parentVC, sender: sender)
        parentVC.navigationController?.pushViewController(messageScreen, animated: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


extension MessageSearchResults: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercased() ?? ""
        
        DispatchQueue.global(qos: .default).async {
                        
            // Search the sender names
            self.filteredSources = AccountNotification.current.keys.filter {
                $0.name.lowercased().contains(searchString) || searchString.isEmpty
            }
                        
            // Search the messages
            self.filteredMessages = AccountNotification.current.map { key, value in
                return (key, value.filter {
                    $0.shortString.string.lowercased().contains(searchString) || searchString.isEmpty
                })
            } . filter { !$0.matches.isEmpty }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.emptyLabel.isHidden = !self.filteredSources.isEmpty || !self.filteredMessages.isEmpty
            }
        }
    }
    
}
