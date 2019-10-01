//
//  PurchaseDetails.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class PurchaseDetails: UITableViewController {
    
    private var ticket: Ticket!
    private var loadingBG: UIView!
    
    private var historyUsers = [User]()

    required init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        
        self.ticket = ticket
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Transaction Details"
        view.backgroundColor = EventDraft.backgroundColor
        tableView = UITableView(frame: .zero, style: .grouped)
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        lookupTransferHistory()
    }
    
    private func lookupTransferHistory() {
        
        loadingBG.isHidden = false
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/LookupTransferHistory",
                           parameters: ["ticketId": ticket.ticketID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
            
            if let json = try? JSON(data: data!), let userArray = json.array {
                var tmp = [User]()
                for userData in userArray {
                    tmp.append(User(userInfo: userData))
                }
                self.historyUsers = tmp
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if historyUsers.isEmpty { return 0 }
        if !ticket.transferable { return 1 }
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [historyUsers.isEmpty ? 0 : 1, historyUsers.count][section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Ticket details", "Transfer history"][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return PurchaseDetailsCell(ticket: ticket)
        case 1:
            let cell = TransferHistoryUser(user: historyUsers[indexPath.row])
            cell.hasUserAbove = indexPath.row > 0
            cell.hasUserBelow = indexPath.row + 1 < historyUsers.count
            cell.isLocked = !ticket.transferable
            cell.toggleTransferable = { on in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                if on {
                    alert.title = "Make this ticket transferable?"
                    alert.message = "The owner of the ticket will be able to transfer its ownership to another user."
                } else {
                    alert.title = "Make this ticket untransferable?"
                    alert.message = "The owner of the ticket will not be able to transfer it to anyone else."
                }
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(.init(title: "Continue", style: .default, handler: { _ in
                    self.toggleTransferable(cell: cell, on: on)
                }))
                self.present(alert, animated: true)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func toggleTransferable(cell: TransferHistoryUser, on: Bool) {
        
        loadingBG.isHidden = false
        (loadingBG.subviews.last as? UILabel)?.text = "Updating..."
        
        let parameters = [
            "ticketId": ticket.ticketID,
            "transferable": on ? "1" : "0"
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ToggleTransferable",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                DispatchQueue.main.async {
                    cell.isLocked.toggle()
                }
            default:
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            
        }
        
        task.resume()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
