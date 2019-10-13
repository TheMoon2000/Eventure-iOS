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
    
    private var generateQuantity = 1
    private var salesBundle = [String]()
    
    var doneHandler: ((Bool) -> ())?
        
    required init(parentVC: IssuedTickets, ticketToEdit: Ticket? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        if ticketToEdit == nil {
            draftTicket = Ticket(ticketInfo: JSON())
            draftTicket.ticketID = UUID().uuidString.lowercased()
            draftTicket.admissionID = parentVC.admissionType.id
            draftTicket.ticketPrice = parentVC.admissionType.price ?? 0.0
            draftTicket.paymentType = .issued
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
        tableView.backgroundColor = AppColors.canvas
        
        let sizeCell: UITableViewCell = {
            let cell = DraftCapacityCell(title: "Ticket size:")
            cell.valueField.placeholder = "1"
            cell.valueField.returnKeyType = .next
            cell.valueField.autocapitalizationType = .none
            cell.valueField.autocorrectionType = .no
            cell.valueField.isUserInteractionEnabled = draftTicket.activationDate == nil
            cell.changeHandler = { tf in
                self.draftTicket.quantity = Int(tf.text!) ?? 1
            }
            cell.returnHandler = { tf in
                tf.resignFirstResponder()
            }
            if !newTicket {
                cell.valueField.text = String(draftTicket.quantity)
            }
            
            return cell
        }()
        contentCells.append(sizeCell)
        
        let quantityCell: UITableViewCell = {
            let cell = DraftCapacityCell(title: "How many tickets:")
            cell.valueField.placeholder = "1"
            cell.valueField.returnKeyType = .next
            cell.valueField.autocapitalizationType = .none
            cell.valueField.autocorrectionType = .no
            cell.valueField.isUserInteractionEnabled = draftTicket.activationDate == nil
            cell.changeHandler = { tf in
                self.generateQuantity = Int(tf.text!) ?? 0
                self.salesBundle.removeAll()
                if (self.generateQuantity > 0) {
                    for _ in 1...self.generateQuantity {
                        self.salesBundle.append(UUID().uuidString.lowercased())
                    }
                }
            }
            cell.returnHandler = { tf in
                tf.resignFirstResponder()
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
            if draftTicket.transactionDate == nil {
                cell.promptLabel.text = "Recipient email"
            } else {
                cell.promptLabel.text = "The ticket has already been claimed by the user associated with the email below and cannot be modified further."
                cell.valueText.isEditable = false
            }
            cell.returnHandler = { tv in
                let notesCell = self.contentCells.last as? DraftLocationCell
                notesCell?.valueText.becomeFirstResponder()
            }
            cell.textChangeHandler = { tv in
                self.draftTicket.userEmail = tv.text
            }
            
            return cell
        }()
        contentCells.append(emailCell)
        
        let transferCell: UITableViewCell = {
            let cell = SettingsSwitchCell()
            cell.titleLabel.text = "Transferable:"
            cell.enabled = draftTicket.transferable
            cell.switchHandler = { on in
                self.draftTicket.transferable = on
            }
            
            return cell
        }()
        contentCells.append(transferCell)
        
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
        
        if let quota = parentVC.admissionType.quota, quota > 0 && parentVC.admissionType.quantitySold + draftTicket.quantity > quota {
            let alert = UIAlertController(title: "You are overselling tickets!", message: "You are about to create more tickets than the quota for '\(parentVC.admissionType.typeName)'! If you would like to add these tickets, please first go to the event editor and increase the quota for this ticket type. The current quota is \(quota).", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return
        }

        navigationItem.rightBarButtonItem = spinnerItem
        //print(draftTicket.salesID.description)
        for id in self.salesBundle {
            self.createTicketsWithBundle(uuid: id)
        }
        
    }
    private func createTicketsWithBundle(uuid: String) {
        var parameters = [
            "eventId": parentVC.event.uuid,
            "ticketId": uuid,
            "quantity": String(draftTicket.quantity),
            "admissionId": draftTicket.admissionID,
            "price": String(draftTicket.ticketPrice),
            "transferable": draftTicket.transferable ? "1" : "0",
            "notes": draftTicket.notes
        ]
        
        if draftTicket.userEmail?.isValidEmail() ?? false {
            //print(draftTicket.userEmail)
            parameters["email"] = draftTicket.userEmail!
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
                    self.doneHandler?(self.newTicket)
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
        
        if newTicket {
            (contentCells[0] as? DraftCapacityCell)?.valueField.becomeFirstResponder()
        }
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
