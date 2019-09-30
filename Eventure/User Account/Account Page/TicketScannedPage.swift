//
//  TicketScannedPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/29.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketScannedPage: UIViewController {
    
    private var ticket: Ticket!
    private var parentVC: UserScanner!
    
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    private var eventTitle: UILabel!
    private var quantity: UILabel!
    private var claimButton: UIButton!
    private var loadingBG: UIView!
    
    required init(ticket: Ticket, parentVC: UserScanner) {
        super.init(nibName: nil, bundle: nil)
        
        self.ticket = ticket
        self.parentVC = parentVC
        title = "Ticket Info"
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(close))
        
        orgLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            if ticket.orgLogo != nil {
               iv.image = ticket.orgLogo
            } else {
                ticket.getLogoImage { ticketWithLogo in
                    iv.image = ticketWithLogo.orgLogo
                }
            }
            iv.tintColor = MAIN_DISABLED
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)
           
            iv.widthAnchor.constraint(equalToConstant: 75).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
           
            return iv
        }()


        orgTitle = {
            let label = UILabel()
            label.text = ticket.hostName + "'s"
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.numberOfLines = 5
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 35).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
            label.topAnchor.constraint(equalTo: orgLogo.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        eventTitle = {
            let label = UILabel()
            label.text = ticket.eventName
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.textAlignment = .center
            label.numberOfLines = 5
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 35).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
            label.topAnchor.constraint(equalTo: orgTitle.bottomAnchor, constant: 15).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            
            return label
        }()
        
        quantity = {
            let label = UILabel()
            label.text = "\(ticket.quantity) × \(ticket.typeName) Ticket"
            label.numberOfLines = 3
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: eventTitle.leftAnchor, constant: 5).isActive = true
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor, constant: -5).isActive = true
            label.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 10).isActive = true
            let c = label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -60)
            c.priority = .defaultLow
            c.isActive = true
            
            return label
        }()
        
        claimButton = {
            let button = UIButton(type: .system)
            button.setTitle("Request Ticket Transfer", for: .normal)
            button.tintColor = .white
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.backgroundColor = MAIN_TINT
            button.layer.cornerRadius = 10
            button.contentEdgeInsets.left = 30
            button.contentEdgeInsets.right = 30
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 53).isActive = true
            let b = button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
            b.priority = .defaultLow
            b.isActive = true
            button.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
            button.topAnchor.constraint(greaterThanOrEqualTo: quantity.bottomAnchor, constant: 30).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                        
            return button
        }()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedTransferStatus(_:)), name: TICKET_TRANSFER_STATUS, object: nil)
      
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func receivedTransferStatus(_ notification: Notification) {
        
        guard let result = notification.object as? (success: Bool, ticketID: String), result.ticketID == ticket.ticketID else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        if result.success {
            alert.title = "Transfer request approved!"
            let noun = ticket.quantity == 1 ? "ticket" : "tickets"
            alert.message = "You are now the owner of \(ticket.quantity) × \(ticket.typeName) \(noun) for '\(ticket.eventName)'."
            alert.addAction(.init(title: "Great", style: .cancel, handler: { _ in
                Ticket.updateTickets()
                self.dismiss(animated: true)
            }))
        } else {
            alert.title = "Ticket transfer rejected"
            alert.message = "Your ticket transfer request was declined by the ticket owner."
            alert.addAction(.init(title: "OK", style: .cancel, handler: { _ in
                self.dismiss(animated: true)
            }))
        }
        present(alert, animated: true)
    }
    
    @objc private func buttonPressed() {
        
        loadingBG.isHidden = false
        
        let parameters = [
            "userId": String(User.current!.uuid),
            "ticketId": ticket.ticketID
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/InitiateTicketTransfer",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            switch msg {
            case "success":
                DispatchQueue.main.async {
                    self.claimButton.isUserInteractionEnabled = false
                    self.claimButton.setTitle("Request Pending...", for: .normal)
                    self.claimButton.backgroundColor = MAIN_DISABLED
                }
            default:
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
        
        task.resume()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    

}
