//
//  TicketTypes.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketTypes: UITableViewController {
    
    private var draftPage: EventDraft!
    
    private var sortedAdmissionTypes = [AdmissionType]()
    private var emptyLabel: UILabel!
    
    required init(draftPage: EventDraft) {
        super.init(nibName: nil, bundle: nil)
        
        self.draftPage = draftPage
        
        title = "Ticket Types"
        view.backgroundColor = EventDraft.backgroundColor
        sortedAdmissionTypes = draftPage.draft.admissionTypes.sorted { t1, t2 in
            (t1.price ?? 0.0) >= (t2.price ?? 0.0)
        }
    }
    
    func resortAndReload() {
        sortedAdmissionTypes.sort { ($0.price ?? 0.0) >= ($1.price ?? 0.0) }
        draftPage.draft.admissionTypes = sortedAdmissionTypes
        emptyLabel.isHidden = !sortedAdmissionTypes.isEmpty
        draftPage.edited = true
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.register(TicketTypeCell.classForCoder(), forCellReuseIdentifier: "ticket type")
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addTicket))
        
        emptyLabel = {
            let label = UILabel()
            label.isHidden = !draftPage.draft.admissionTypes.isEmpty
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
        return sortedAdmissionTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket type", for: indexPath) as! TicketTypeCell
        
        let admission = sortedAdmissionTypes[indexPath.row]
        cell.titleLabel.text = admission.typeName
        cell.valueLabel.text = "$" + admission.priceDescription

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TicketInfoEditor(parentVC: self, admissionInfo: sortedAdmissionTypes[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "Delete ticket type?", message: "There is no going back. User who have already purchased this type of ticket will be unaffected.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Delete", style: .destructive, handler: {_ in
                self.sortedAdmissionTypes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.draftPage.draft.admissionTypes = self.sortedAdmissionTypes
                self.draftPage.edited = true
            }))
            self.present(alert, animated: true)
        })
        
        action.backgroundColor = FATAL_COLOR
        
        return [action]
    }
 
    
    @objc private func addTicket() {
        let newType = AdmissionType.new
        sortedAdmissionTypes.append(newType)
        let vc = TicketInfoEditor(parentVC: self, admissionInfo: newType)
        navigationController?.pushViewController(vc, animated: true)
    }
        

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
