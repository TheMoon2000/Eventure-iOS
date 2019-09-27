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
    
    required init(parentVC: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = parentVC.event
        self.sortedTypes = event.admissionTypes.sorted(by: { (t1, t2) -> Bool in
            return (t1.price ?? 0.0) >= (t2.price ?? 0.0)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buy Tickets"
        view.backgroundColor = EventDraft.backgroundColor

        tableView.separatorStyle = .none
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 5
        tableView.tableFooterView = UIView()
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
                self.initiateRequest()
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.buyButton.frame
            }
            
            self.present(alert, animated: true)
        }
        return cell
    }
    
    private func initiateRequest() {
        let vc = InitiateTicketRequest(event: self.event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
