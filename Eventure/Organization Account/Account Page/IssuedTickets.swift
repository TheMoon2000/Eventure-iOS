//
//  IssuedTickets.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class IssuedTickets: UITableViewController, IndicatorInfoProvider {

    private var event: Event!
    private var admissionType: AdmissionType!
    
    /// Incomplete registrant information, only using it as a data structure to hold partial information
    var tickets = [Ticket]()
    
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
        tableView.register(IssuedTicketCell.classForCoder(), forCellReuseIdentifier: "ticket")
        
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
        
        loadTickets()
    }
    
    @objc private func refresh() {
        loadTickets(pulled: true)
    }
    
    private func loadTickets(pulled: Bool = false) {
        
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
                    self.emptyLabel.text = CONNECTION_ERROR
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), json.array != nil {
                var newRecords = [Ticket]()
                for purchase in json.array! {
                    let newTicket = Ticket(ticketInfo: purchase)
                    if newTicket.paymentType == .none {
                        newRecords.append(newTicket)
                    }
                }
                self.tickets = newRecords
                DispatchQueue.main.async {
                    self.emptyLabel.text = self.tickets.isEmpty ? "No issued tickets" : ""
                    self.tableView.reloadData()
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
        return tickets.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket", for: indexPath) as! IssuedTicketCell
        
        cell.setup(ticket: tickets[indexPath.row])
        
        
        return cell
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Issued")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
