//
//  TicketDetails.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketDetails: UITableViewController {
    
    private var ticket: Ticket!
    
    private var contentCells = [[UITableViewCell]]()
    
    required init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        
        self.ticket = ticket
        
        // Section 0
        
        let eventsCell: EventsCell = {
            let cell = EventsCell()
            cell.setDisplayedDate(start: ticket.eventDate, end: ticket.eventEndDate)
            
            return cell
        }()
        
        contentCells.append([eventsCell])
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = EventDraft.backgroundColor
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Event details"][section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.section][indexPath.row]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
