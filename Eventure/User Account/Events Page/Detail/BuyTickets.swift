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
        return BuyTicketCell(admissionType: sortedTypes[indexPath.row])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
