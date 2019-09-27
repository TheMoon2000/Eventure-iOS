//
//  InitiateTicketRequest.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class InitiateTicketRequest: UITableViewController {
    
    private var event: Event!
    
    private var contentCells = [UITableViewCell]()
    private var spinnerItem: UIBarButtonItem!
    
    // Used for ticket request
    private var quantity = 1
    
    required init(event: Event!) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Initiate Ticket Request"
        view.backgroundColor = EventDraft.backgroundColor

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 5
        
        let spinner = UIActivityIndicatorView()
        spinner.color = .lightGray
        spinner.startAnimating()
        spinnerItem = UIBarButtonItem(customView: spinner)
        
        let quantityCell: DraftCapacityCell = {
            let cell = DraftCapacityCell(title: "Quantity:")
            cell.valueField.placeholder = "1"
            cell.changeHandler = { tf in
                self.quantity = Int(tf.text!) ?? 1
            }
            
            return cell
        }()
        contentCells.append(quantityCell)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
