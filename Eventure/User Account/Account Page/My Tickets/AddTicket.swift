//
//  AddTicket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddTicket: UITableViewController {
    
    private var parentVC: TicketsList!
    var textCell: GenericTextCell!
    
    required init(parentVC: TicketsList) {
        super.init(nibName: nil, bundle: nil)
        
        title = "Redeem Ticket"
        self.parentVC = parentVC
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.keyboardDismissMode = .interactive
        
        textCell = GenericTextCell(title: "XXXX-XXXX-XXXX")
        textCell.inputField.keyboardType = .asciiCapable
        textCell.inputField.returnKeyType = .go
        textCell.inputField.autocorrectionType = .no
        textCell.inputField.autocapitalizationType = .allCharacters
        textCell.inputField.inputAccessoryView = makeAccessoryView()
        textCell.submitAction = { field, spinner in
            self.view.endEditing(true)
            spinner.startAnimating()
            self.applyCode(code: field.text!) {
                spinner.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textCell.inputField.becomeFirstResponder()
    }
    
    /// Make keyboard accessory view
    
    private func makeAccessoryView() -> UIView {
        
        let signButton = UIButton(type: .system)
        signButton.setTitle("–", for: .normal)
        signButton.tintColor = AppColors.main
        signButton.titleLabel?.font = .appFontRegular(18)
        signButton.addTarget(self, action: #selector(dash), for: .touchUpInside)
        signButton.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.92, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signButton)
        view.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        
        NSLayoutConstraint.activate([
            signButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signButton.widthAnchor.constraint(equalToConstant: 32)
        ])
        return view
    }
    
    @objc private func dash() {
        textCell.inputField.text = textCell.inputField.text! + "-"
    }
    
    private func applyCode(code: String, _ completion: (() -> ())?) {
        
        let parameters = [
            "userId": String(User.current!.uuid),
            "code": code
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/RedeemTicket",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                completion?()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), let result = json.dictionary {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                
                if result["success"]!.boolValue, let quantity = result["quantity"]?.int {
                    alert.title = "Ticket added succesfully!"
                    let noun = quantity == 1 ? "ticket" : "tickets"
                    var admissionType = ""
                    if let a = result["Type name"]?.string {
                        admissionType = " (\(a))"
                    }
                    alert.message = "You have just received \(quantity) \(noun) for '\(result["event"] ?? "<event name>")'\(admissionType)."
                    
                    alert.addAction(.init(title: "OK", style: .cancel, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    DispatchQueue.main.async {
                        self.parentVC.getTickets()
                        self.present(alert, animated: true)
                    }
                } else {
                    alert.title = "Could not add ticket"
                    alert.message = result["message"]?.string ?? "An known error has occurred."
                    alert.addAction(.init(title: "OK", style: .cancel))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
                
                
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.title = "Could not add ticket"
                alert.message = "An known error has occurred."
                alert.addAction(.init(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Enter Ticket Code"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "If you have already acquired one or more tickets for an event, please enter the ticket code to redeem them."
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return textCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = .appFontRegular(13.5)
        }
    }
    
    @objc private func addTicket() {
        textCell.submit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
