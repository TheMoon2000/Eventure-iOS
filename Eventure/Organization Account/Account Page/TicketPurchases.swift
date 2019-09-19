//
//  TicketPurchases.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class TicketPurchases: UITableViewController, IndicatorInfoProvider {
    
    private var event: Event!
    private var admissionType: AdmissionType!
    
    /// Incomplete registrant information, only using it as a data structure to hold partial information
    var purchases = [(registrant: Registrant, ticket: Ticket)]()
    var profileCache = [Int : UIImage]()
    
    private var rc = UIRefreshControl()
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    
    required init(event: Event!, admissionType: AdmissionType) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.admissionType = admissionType
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.backgroundColor = EventDraft.backgroundColor
        tableView.register(CheckinUserCell().classForCoder, forCellReuseIdentifier: "user")
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        loadPurchases()
    }
    
    @objc private func refresh() {
        loadPurchases(pulled: true)
    }
    
    private func loadPurchases(pulled: Bool = false) {
        
        emptyLabel.text = ""
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ListPurchases",
                           parameters: ["eventId": event.uuid,
                                        "type": admissionType.typeName])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                if !pulled {
                    self.loadingBG.isHidden = true
                    self.tableView.refreshControl = self.rc
                } else {
                    self.rc.endRefreshing()
                }
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
                    serverMaintenanceError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), json.array != nil {
                var newRecords = [(Registrant, Ticket)]()
                for purchase in json.array! {
                    let registrant = Registrant(json: purchase)
                    registrant.profilePicture = self.profileCache[registrant.userID]
                    newRecords.append((
                        registrant,
                        Ticket(ticketInfo: purchase)
                    ))
                }
                self.purchases = newRecords
                DispatchQueue.main.async {
                    self.emptyLabel.text = self.purchases.isEmpty ? "No purchase record to show." : ""
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = CONNECTION_ERROR
                }
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")
            }
        }
        
        task.resume()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as! CheckinUserCell
        
        let purchaseInfo = purchases[indexPath.row]

        cell.nameLabel.text = purchaseInfo.registrant.displayedName
        if cell.nameLabel.text!.isEmpty {
            cell.nameLabel.text = purchaseInfo.registrant.name
            if cell.nameLabel.text!.isEmpty {
                cell.nameLabel.text = purchaseInfo.registrant.email
            }
        }
        if purchaseInfo.registrant.profilePicture == nil {
            purchaseInfo.registrant.getProfilePicture { new in
                if new.profilePicture != nil {
                    cell.profilePicture.image = new.profilePicture
                    self.profileCache[new.userID] = new.profilePicture
                }
            }
        }
        let noun = purchaseInfo.ticket.quantity == 1 ? "Ticket" : "Tickets"
        cell.majorLabel.text = "\(purchaseInfo.ticket.quantity) " + noun

        return cell
    }
 
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Purchases")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
