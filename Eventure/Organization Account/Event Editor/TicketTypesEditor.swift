//
//  TicketTypesEditor.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketTypesEditor: UITableViewController {
    
    private var event: Event!
    private var sortedTickets = [(type: String, info: [String : Any])]()
    
    private var emptyLabel: UILabel!
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Ticket Types"
        view.backgroundColor = EventDraft.backgroundColor
        self.event = event
        sortedTickets = event.admissionTypes.sorted { t1, t2 in
            return (t1.value["Price"] as! Double) >= (t2.value["Price"] as! Double)
        } as! [(type: String, info: [String : Any])]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.register(TicketTypeCell.classForCoder(), forCellReuseIdentifier: "ticket type")
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.textAlignment = .center
            label.textColor = .gray
            label.text = "No tickets configured"
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedTickets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket type", for: indexPath) as! TicketTypeCell
        
        let admission = sortedTickets[indexPath.row]
        cell.setup(typeName: admission.type, price: admission.info["Price"] as! Double)

        return cell
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
