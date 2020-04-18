//
//  BuyTickets.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class BuyTickets: UITableViewController {
    
    private var event: Event!
    private var sortedTypes = [AdmissionType]()
    
    private var loadingBG: UIView!
    private var emptyLabel: UILabel!
    private var rc = UIRefreshControl()
    
    required init(parentVC: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = parentVC.event
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buy Tickets"
        view.backgroundColor = AppColors.canvas

        tableView.separatorStyle = .none
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.tableFooterView = UIView()
        
        loadingBG = view.addLoader()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        rc.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        rc.tintColor = AppColors.lightControl
        
        updateTickets()
    }
    
    @objc private func pullRefresh() {
        updateTickets(pulled: true)
    }
    
    private func updateTickets(pulled: Bool = false) {
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        emptyLabel.text = ""
        
        event.updateAdmissionTypes { success in
            self.loadingBG.isHidden = true
            if pulled {
                self.rc.endRefreshing()
            } else {
                self.tableView.refreshControl = self.rc
            }
            
            if !success {
                let alert = UIAlertController(title: "Unable to load tickets", message: "We could not communicate with our server. Perhaps there is a connection problem?", preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(.init(title: "Retry", style: .default, handler: { _ in
                    self.updateTickets()
                }))
            } else {
                self.sortedTypes = self.event.admissionTypes.sorted(by: { (t1, t2) -> Bool in
                    return (t1.price ?? 0.0) >= (t2.price ?? 0.0)
                })
                if self.sortedTypes.isEmpty {
                    self.emptyLabel.text = "No tickets available"
                }
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BuyTicketCell(admissionType: sortedTypes[indexPath.row])
        cell.buyHandler = { type in
            let alert = UIAlertController(title: "Select payment type", message: "We're still figuring out the best way to carry out payments in Eventure. In the mean time, please reach out to the event organizer first to complete the payment and then request your ticket(s).", preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Request Paid Ticket", style: .default, handler: { _ in
                self.initiateRequest(type: cell.admissionType)
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.buyButton.frame
            }
            
            self.present(alert, animated: true)
        }
        return cell
    }
    
    private func initiateRequest(type: AdmissionType) {
        let vc = InitiateTicketRequest(event: self.event, admissionType: type)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let admissionType = sortedTypes[indexPath.row]
        if !admissionType.notes.isEmpty {
            let alert = UIAlertController(title: admissionType.typeName, message: admissionType.notes, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "Close", style: .cancel))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = tableView
                popoverController.sourceRect = tableView.rectForRow(at: indexPath)
            }
            
            present(alert, animated: true)
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
