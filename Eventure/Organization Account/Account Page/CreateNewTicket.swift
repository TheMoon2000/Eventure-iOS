//
//  CreateNewTicket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CreateNewTicket: UITableViewController {
    
    private var parentVC: IssuedTickets!
    private var contentCells = [UITableViewCell]()
    
    private var newTicket = true
    private var draftTicket: Ticket!
    
    private var buttonItem: UIBarButtonItem!
    private var spinnerItem: UIBarButtonItem!
        
    required init(parentVC: IssuedTickets, ticketToEdit: Ticket? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        if ticketToEdit == nil {
            draftTicket = Ticket(ticketInfo: JSON())
            draftTicket.ticketID = UUID().uuidString.lowercased()
            draftTicket.admissionType = parentVC.admissionType.typeName
            draftTicket.ticketPrice = parentVC.admissionType.price ?? 0.0
            draftTicket.paymentType = .offline
        } else {
            newTicket = false
            draftTicket = ticketToEdit!
        }
        
        let spinner = UIActivityIndicatorView()
        spinner.color = .lightGray
        spinner.startAnimating()
        spinnerItem = UIBarButtonItem(customView: spinner)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Ticket"
        buttonItem = .init(title: "Done", style: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = buttonItem

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = EventDraft.backgroundColor
        
        let quantityCell: UITableViewCell = {
            let cell = DraftCapacityCell(title: "Party size:")
            cell.valueField.placeholder = "1"
            cell.valueField.returnKeyType = .next
            cell.valueField.autocapitalizationType = .none
            cell.valueField.autocorrectionType = .no
            cell.valueField.isUserInteractionEnabled = draftTicket.activationDate == nil
            cell.changeHandler = { tf in
                self.draftTicket.quantity = Int(tf.text!) ?? 1
                tf.text = String(self.draftTicket.quantity)
            }
            cell.returnHandler = { tf in
                let emailCell = self.contentCells[1] as? DraftLocationCell
                emailCell?.valueText.becomeFirstResponder()
            }
            if !newTicket {
                cell.valueField.text = String(draftTicket.quantity)
            }
            
            return cell
        }()
        contentCells.append(quantityCell)
        
        let emailCell: UITableViewCell = {
            let cell = DraftLocationCell()
            cell.setPlaceholder(string: "Optional")
            cell.multiLine = false
            cell.valueText.insertText(draftTicket.userEmail ?? "")
            cell.valueText.returnKeyType = .next
            cell.valueText.keyboardType = .emailAddress
            cell.valueText.autocapitalizationType = .none
            cell.valueText.autocorrectionType = .no
            cell.valueText.isEditable = draftTicket.activationDate == nil
            if draftTicket.activationDate == nil {
                cell.promptLabel.text = "Recipient email (Leave blank if this ticket can be redeemed by anyone with the code):"
            } else {
                cell.promptLabel.text = "The ticket has already been claimed by the user associated with the email below and cannot be modified further."
            }
            cell.returnHandler = { tv in
                let notesCell = self.contentCells[2] as? DraftLocationCell
                notesCell?.valueText.becomeFirstResponder()
            }
            cell.textChangeHandler = { tv in
                self.draftTicket.userEmail = tv.text
            }
            
            return cell
        }()
        contentCells.append(emailCell)
        
        let notesCell: UITableViewCell = {
            let cell = DraftLocationCell()
            cell.promptLabel.text = "Additional comments:"
            cell.setPlaceholder(string: "Optional")
            cell.valueText.insertText(draftTicket.notes)
            cell.textChangeHandler = { tv in
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
                self.draftTicket.notes = tv.text
            }
            
            return cell
        }()
        contentCells.append(notesCell)
    }
    
    @objc private func done() {

        navigationItem.rightBarButtonItem = spinnerItem
        
        var parameters = [
            "eventId": parentVC.event.uuid,
            "ticketId": draftTicket.ticketID,
            "quantity": String(draftTicket.quantity),
            "type": draftTicket.admissionType,
            "price": String(draftTicket.ticketPrice),
            "notes": draftTicket.notes
        ]
        
        if draftTicket.userEmail?.isValidEmail() ?? false {
            parameters["email"] = draftTicket.userEmail
        }
                
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/AddTicket",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.buttonItem
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                DispatchQueue.main.async {
                    if self.newTicket {
                        self.parentVC.loadTickets()
                    } else {
                        self.parentVC.sortAndReload()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alert.addAction(.init(title: "Dismiss", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
        
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        (contentCells[0] as? DraftCapacityCell)?.valueField.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }


}
