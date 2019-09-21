//
//  ActivateTicket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class ActivateTicket: UIViewController {
    
    private var event: Event?
    private var ticketID: String!
    
    private var canvas: UIScrollView!
    private var loadingBG: UIView!
    private var message: UILabel!
    private var doneIcon: UIImageView!
    private var dismissButton: UIButton!
    
    required init(ticketID: String, event: Event?) {
        super.init(nibName: nil, bundle: nil)
        
        self.ticketID = ticketID
        self.event = event
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        canvas = {
            let canvas = UIScrollView()
            canvas.isHidden = true
            canvas.alwaysBounceVertical = true
            canvas.contentInsetAdjustmentBehavior = .always
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        message = {
            let label = UILabel()
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 35).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
            
            let c = label.centerYAnchor.constraint(equalTo: canvas.centerYAnchor)
            c.priority = .defaultHigh
            c.isActive = true
            
            return label
        }()
        
        doneIcon = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "done"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 75).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            iv.bottomAnchor.constraint(equalTo: message.topAnchor, constant: -30).isActive = true
            iv.centerYAnchor.constraint(greaterThanOrEqualTo: canvas.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
            
            return iv
        }()
        
        dismissButton = {
            let button = UIButton(type: .system)
            button.setTitle("Done", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.tintColor = .white
            button.backgroundColor = MAIN_TINT
            button.layer.cornerRadius = 10
        
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 240).isActive = true
            button.heightAnchor.constraint(equalToConstant: 54).isActive = true
            button.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 100).isActive = true
            button.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -70).isActive = true
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            return button
        }()
        
        activateTicket()
    }
    
    func activateTicket(overrideCapacity: Bool = false) {
        
        loadingBG.isHidden = false
        
        var parameters = [
            "orgId": Organization.current!.id,
            "ticketId": ticketID!,
            "overrideCapacity": overrideCapacity ? "1" : "0"
        ]
        
        parameters["eventId"] = event?.uuid
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ActivateTicket",
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
                    let alert = UIAlertController(title: "Cannot communicate with the server!", message: "Looks like your internet connection is unstable. Would you like to try again?", preferredStyle: .alert)
                    alert.addAction(.init(title: "Close", style: .cancel, handler: { _ in
                        self.dismiss(animated: true)
                    }))
                    alert.addAction(.init(title: "Retry", style: .default, handler: { _ in
                        self.activateTicket(overrideCapacity: overrideCapacity)
                    }))
                    self.present(alert, animated: true)
                }
                return
            }
            
            if  let json = try? JSON(data: data!),
                let returnData = json.dictionary,
                let status = returnData["status"]?.int {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { _ in
                    self.dismiss(animated: true)
                }))
                switch status {
                case -1:
                    alert.title = "Your event is overloaded"
                    alert.message = "Your event's occupancy has already reached its capacity. Proceed check-in anyway?"
                    alert.addAction(.init(title: "Proceed", style: .default, handler: { _ in
                        self.activateTicket(overrideCapacity: true)
                    }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                case 0:
                    alert.title = "Check-in failure"
                    alert.message = returnData["message"]?.string ?? "An unknown error has occurred."
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                case 1:
                    DispatchQueue.main.async {
                        self.checkinSuccess(info: returnData)
                    }
                default:
                    alert.title = "Check-in failure"
                    alert.message = "An internal error has occurred."
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                }
                
                
                
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }

    
    func checkinSuccess(info: [String : JSON]) {
        guard let admissionType = info["Admission type"]?.string else {
            print("WARNING: Admission type not found")
            return
        }
        
        guard let displayedName = info["Username"]?.string else {
            print("WARNING: Username not found")
            return
        }
        
        let quantity = info["Quantity"]?.int ?? 1
        let quantityInfo = quantity == 1 ? "" : "(party size = \(quantity)) "
        let eventInfo = event == nil ? " of event *\(info["Event title"]!)*" : ""
        
        message.attributedText = ("**\(displayedName)** " + quantityInfo + "is successfully checked in for admission type  **\(admissionType)**\(eventInfo).").attributedText(style: TITLE_STYLE)
        message.textAlignment = .center
        canvas.isHidden = false
    }
    
    @objc private func buttonPressed() {
        self.dismiss(animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
