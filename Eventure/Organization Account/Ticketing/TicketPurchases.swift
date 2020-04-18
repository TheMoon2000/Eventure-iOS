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
    
    private var parentVC: TicketManagerMain!
    private var event: Event!
    private var admissionType: AdmissionType {
        return parentVC.admissionType
    }
    
    /// Incomplete registrant information, only using it as a data structure to hold partial information
    var purchases = [(registrant: Registrant, ticket: Ticket)]()
    var profileCache = [Int : UIImage]()
    
    private var rc = UIRefreshControl()
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    
    required init(parentVC: TicketManagerMain) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = parentVC.event
        self.parentVC = parentVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        parentVC.navigationItem.backBarButtonItem = .init(title: "Purchases", style: .plain, target: nil, action: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.backgroundColor = AppColors.canvas
        tableView.register(CheckinUserCell().classForCoder, forCellReuseIdentifier: "user")
        
        loadingBG = view.addLoader()
        
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
        rc.tintColor = AppColors.lightControl
        
        loadPurchases()
    }
    
    @objc private func refresh() {
        loadPurchases(pulled: true)
    }
    
    func loadPurchases(pulled: Bool = false) {
        
        emptyLabel.text = ""
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ListPurchases",
                           parameters: ["eventId": event.uuid,
                                        "admissionId": admissionType.id])!
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
                    self.emptyLabel.text = CONNECTION_ERROR
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), json.array != nil {
                var newRecords = [(Registrant, Ticket)]()
                for purchase in json.array! {
                    let ticket = Ticket(ticketInfo: purchase)
                    let registrant = Registrant(json: purchase)
                    if registrant.email.isEmpty { continue }
                    registrant.profilePicture = self.profileCache[registrant.userID]
                    
                    newRecords.append((registrant, ticket))
                }
                self.purchases = newRecords.sorted(by: { info1, info2 in
                    return (info1.1.creationDate ?? Date.distantPast).timeIntervalSince(info2.1.creationDate ?? Date.distantPast) >= 0
                })
                DispatchQueue.main.async {
                    self.emptyLabel.text = self.purchases.isEmpty ? "No purchase records" : ""
                    self.tableView.reloadData()
                    self.parentVC.center.refresh()
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
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
        let cell = CheckinUserCell()
        
        let purchaseInfo = purchases[indexPath.row]

        cell.nameLabel.text = purchaseInfo.registrant.displayedName
        if cell.nameLabel.text!.isEmpty {
            cell.nameLabel.text = purchaseInfo.registrant.name
        }
        if cell.nameLabel.text!.isEmpty {
            cell.nameLabel.text = purchaseInfo.registrant.email
        }
        if cell.nameLabel.text!.isEmpty {
            cell.nameLabel.text = "No email provided"
        }
        cell.auxiliaryLabel.text = purchaseInfo.ticket.paymentDescription
        
        
        if purchaseInfo.registrant.profilePicture == nil {
            purchaseInfo.registrant.getProfilePicture { new in
                if new.profilePicture != nil {
                    cell.profilePicture.image = new.profilePicture
                    self.profileCache[new.userID] = new.profilePicture
                }
            }
        } else {
            cell.profilePicture.image = purchaseInfo.registrant.profilePicture
        }
        let noun = purchaseInfo.ticket.quantity == 1 ? "Ticket" : "Tickets"
        cell.majorLabel.text = "\(purchaseInfo.ticket.quantity) " + noun

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PurchaseDetails(ticket: purchases[indexPath.row].ticket)
        navigationController?.pushViewController(vc, animated: true)
    }
 
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Purchases")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
