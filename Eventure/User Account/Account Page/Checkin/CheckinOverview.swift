//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckinOverview: UIViewController {
    
    private var event: Event!
    private var sheetInfo: SignupSheet?
    
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    private var invitesTo: UILabel!
    private var eventTitle: UILabel!
    private var checkinButton: UIButton!
    private var captionLabel: UILabel!
    
    private var checkbox: UICheckbox!
    private var checkboxLabel: UILabel!
    private var consentStack: UIStackView!
    
    private var blocker: UIView!
    private var spinner: UIActivityIndicatorView!
    
    private var readyToDisplay: Bool {
        return orgLogo.image != nil && sheetInfo != nil
    }
    
    required init(event: Event!) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        loadLogoImage()
        loadSheetInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        orgLogo = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 110).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.text = event.hostTitle
            label.font = .systemFont(ofSize: 22, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerXAnchor.constraint(equalTo: orgLogo.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: orgLogo.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        invitesTo = {
            let label = UILabel()
            label.text = "invites you to"
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17.5)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: orgTitle.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: orgTitle.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        eventTitle = {
            let label = UILabel()
            label.text = event.title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: invitesTo.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        checkinButton = {
            let button = UIButton(type: .system)
            button.tintColor = .white
            button.setTitle("Check In", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.backgroundColor = MAIN_TINT
            button.layer.cornerRadius = 10
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            button.widthAnchor.constraint(equalToConstant: 220).isActive = true
            button.heightAnchor.constraint(equalToConstant: 53).isActive = true
            
            button.addTarget(self, action: #selector(checkin), for: .touchUpInside)
            
            return button
        }()
        
        captionLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            if event.capacity == 0 {
                label.text = "This check-in form has no capacity limit."
            } else {
                label.text = "Retrieving registrant information..."
            }
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: checkinButton.bottomAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        
        checkbox = {
            let check = UICheckbox()
            check.isChecked = true
            check.format(type: .square)
            check.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(check)
            
            check.widthAnchor.constraint(equalToConstant: 20).isActive = true
            check.heightAnchor.constraint(equalTo: check.widthAnchor).isActive = true
            check.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            
            return check
        }()
        
        checkboxLabel = {
            let label = UILabel()
            label.attributedText = "Allow **\(event.hostTitle)** to view my profile information".attributedText(style: COMPACT_STYLE)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: checkbox.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: checkbox.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: checkinButton.topAnchor, constant: -20).isActive = true
            
            
            return label
        }()
        
        
        blocker = {
            let blocker = UIView()
            blocker.backgroundColor = .white
            blocker.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(blocker)
            
            blocker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            blocker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            blocker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            blocker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return blocker
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.tintColor = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            blocker.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: blocker.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: blocker.centerYAnchor).isActive = true
            
            return spinner
        }()
        
    }
    
    @objc private func check() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func showUI() {
        if self.readyToDisplay {
            self.spinner.stopAnimating()
            self.blocker.isHidden = true
            if event.capacity != 0 {
                self.captionLabel.text = "\(sheetInfo!.currentOccupied) / \(event.capacity) spots currently filled"
            }
            if event.capacity > 0 && event.capacity <= sheetInfo!.currentOccupied && !sheetInfo!.currentUserCheckedIn {
                self.checkinButton.isUserInteractionEnabled = false
                self.checkinButton.alpha = DISABLED_ALPHA
                self.checkinButton.setTitle("List is Full", for: .normal)
            } else if sheetInfo!.currentUserCheckedIn {
                self.checkinButton.isUserInteractionEnabled = false
                self.checkinButton.alpha = DISABLED_ALPHA
                self.checkinButton.setTitle("Already Checked In", for: .normal)
            }
        }
    }
    
    private func loadLogoImage() {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": event.hostID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
                return
            }
            
            DispatchQueue.main.async {
                self.orgLogo.image = UIImage(data: data!) ?? #imageLiteral(resourceName: "unknown")
                self.showUI()
            }
    
        }
        
        task.resume()
    }
    
    private func loadSheetInfo() {
        let parameters = [
            "sheetId": event.uuid,
            "userId": String(User.current!.uuid),
            "orgId": event.hostID
        ]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetCheckinSheet",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
                return
            }
            
            if let json = try? JSON(data: data!) {
                self.sheetInfo = SignupSheet(json: json)
                DispatchQueue.main.async {
                    self.showUI()
                }
            } else {
                print(String(data: data!, encoding: .utf8))
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
                return
            }
            
        }
        
        task.resume()
        
    }
    
    
    @objc private func checkin() {
        let parameters: [String: String] = [
            "userId": String(User.current!.uuid),
            "orgId": event.hostID,
            "sheetId": event.uuid,
            "showProfile": checkbox.isChecked ? "1" : "0"
        ]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/Checkin",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8)
            
            switch msg {
            case INTERNAL_ERROR :
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                let alert = UIAlertController(title: "Successfully checked in!", message: "You name is now on the list!", preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            case "full":
                let alert = UIAlertController(title: "You're too late!", message: "Unfortunately, the check-in list for this event has already met its capacity of \(self.event.capacity). Please check-in earlier next time!", preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            default:
                let alert = UIAlertController(title: "Failed to check in :(", message: "For some weird server-side problem, we were unable to get your name onto the checkin list. Be sure to email us at support@eventure-app.com and we'll fix this bug as soon as possible.", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            }
        }
        
        task.resume()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}

