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
    
    private var loadingBG: UIVisualEffectView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    private var contentCells = [[UITableViewCell]]()
    
    required init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Receipt"
        self.ticket = ticket
        
        loadingBG = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            v.layer.cornerRadius = 12
            v.isHidden = true
            v.layer.masksToBounds = true
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.widthAnchor.constraint(equalToConstant: 110).isActive = true
            v.heightAnchor.constraint(equalTo: v.widthAnchor).isActive = true
            v.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return v
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .gray
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            loadingBG.contentView.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: loadingBG.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: loadingBG.centerYAnchor, constant: -10).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading..."
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 15)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            loadingBG.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 8).isActive = true
            
            return label
        }()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.separatorColor = LINE_TINT
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderHeight = 40
        
        // Section 0
        
        let eventsCell: EventsCell = {
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
        }()
        
        contentCells.append([eventsCell])
        
        contentCells.append([TicketQRCell(ticket: ticket)])
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Event details", "Entrance code", "Ticket info"][section]
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
