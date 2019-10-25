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
    private var admissionType: AdmissionType!
    
    private var contentCells = [UITableViewCell]()
    private var spinnerItem: UIBarButtonItem!
    
    // Used for ticket request
    private var quantity = 1
    private var notes = ""
    
    required init(event: Event!, admissionType: AdmissionType) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.admissionType = admissionType
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = .init(title: "Send", style: .done, target: self, action: #selector(initiateRequest))
        
        title = "Initiate Ticket Request"
        view.backgroundColor = AppColors.canvas

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 5
        tableView.contentInset.bottom = 5
        
        let spinner = UIActivityIndicatorView()
        spinner.color = AppColors.lightControl
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
        
        let notesCell: DraftLocationCell = {
            let cell = DraftLocationCell()
            cell.promptLabel.text = "Notes:"
            cell.setPlaceholder(string: "Optional")
            cell.textChangeHandler = { tv in
                self.notes = tv.text
                if self.notes.count > 1000 {
                    self.notes = String(self.notes[self.notes.startIndex..<self.notes.index(self.notes.startIndex, offsetBy: 1000)]) + "... [Content truncated]"
                }
                UIView.performWithoutAnimation {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
            return cell
        }()
        contentCells.append(notesCell)
    }
    
    @objc private func initiateRequest() {
        
        navigationItem.rightBarButtonItem = spinnerItem
        
        let parameters = [
            "userId": String(User.current!.userID),
            "eventId": event.uuid,
            "quantity": String(quantity),
            "admissionId": admissionType.id,
            "payment": String(admissionType.price ?? 0.0),
            "notes": notes
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/InitiateTicketRequest",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = .init(title: "Send", style: .done, target: self, action: #selector(self.initiateRequest))
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
                let noun = self.quantity == 1 ? "ticket" : "tickets"
                let pronoun = self.quantity == 1 ? "It" : "They"
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ticket request sent", message: "Your request for \(self.quantity) \(noun) has been sent to the event organizer. \(pronoun) will appear in Me → My Tickets if approved.", preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel, handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentCells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return contentCells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 0] {
            (contentCells[0] as? DraftCapacityCell)?.valueField.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
