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
    
    private var loadingBG: UIView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    required init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Receipt"
        self.ticket = ticket
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        ticket.getEvent(handler: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ticketActivated(_:)), name: TICKET_ACTIVATED, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.separatorColor = .init(white: 0.85, alpha: 1)
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 40
                
    }
    
    @objc private func ticketActivated(_ notification: Notification) {
        guard let dict = notification.object as? [String : String] else {
            return
        }
        if ticket.eventID == dict["eventId"] {
            ticket.activationDate = DATE_FORMATTER.date(from: dict["date"] ?? "")
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Event details", "Entrance code", "Ticket info"][section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 2][section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell = EventsCell()
            cell.titleLabel.text = ticket.eventName
            cell.setDisplayedDate(start: ticket.eventDate, end: ticket.eventEndDate)
            cell.icon.image = ticket.eventCover
            if ticket.eventCover == nil {
                ticket.fetchEventImage { ticket in
                    cell.icon.image = ticket.eventCover
                }
            }
            
            return cell
        case [1, 0]:
            let cell = TicketQRCell(ticket: ticket)
            cell.separatorInset = .zero
            return cell
        case [1, 1]:
            return TicketDetailInfoCell(ticket: ticket)
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath {
        case [0, 0]:
            self.loadingBG.isHidden = false
            let detailPage = EventDetailPage()
            detailPage.hidesBottomBarWhenPushed = true
            ticket.getEvent { success in
                self.loadingBG.isHidden = true
                if success {
                    detailPage.event = self.ticket.associatedEvent!
                    self.navigationController?.pushViewController(detailPage, animated: true)
                } else {
                    genericError(vc: self)
                }
            }
        default:
            break
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
