//
//  PurchaseDetails.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class PurchaseDetails: UITableViewController {
    
    private var ticket: Ticket!

    required init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        
        self.ticket = ticket
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Transaction Details"
        tableView = UITableView(frame: .zero, style: .grouped)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return PurchaseDetailsCell(ticket: ticket)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
