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
    
    private var parentVC: CheckinPageController!
    private var event: Event!
    private var sheetInfo: SignupSheet!
    
    private var canvas: UIScrollView!
    
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    private var invitesTo: UILabel!
    private var eventTitle: UILabel!
    private var checkinButton: UIButton!
    private var captionLabel: UILabel!
    
    private var checkbox: UICheckbox!
    private var checkboxLabel: UILabel!
    private var consentStack: UIStackView!
    
    private var loadingBG: UIVisualEffectView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    
    private var CHECK_IN = "Check In"
    private var LIST_FULL = "List is Full"
    private var CHECKED_IN = "Checked In"
    
    required init(parentVC: CheckinPageController, event: Event!, sheetInfo: SignupSheet) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        self.event = event
        self.sheetInfo = sheetInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        canvas = {
            let canvas = UIScrollView()
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
        
        let _: UIView = {
            let bg = UIView()
            bg.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(bg)
            
            bg.topAnchor.constraint(equalTo: canvas.topAnchor).isActive = true
            bg.bottomAnchor.constraint(equalTo: canvas.bottomAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            bg.heightAnchor.constraint(greaterThanOrEqualTo: canvas.safeAreaLayoutGuide.heightAnchor).isActive = true
            
            return bg
        }()
        
        orgLogo = {
            let iv = UIImageView()
            iv.backgroundColor = .init(white: 0.95, alpha: 1)
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 110).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 35).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.text = event.hostTitle
            label.font = .systemFont(ofSize: 22, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
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
            canvas.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: orgTitle.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: orgTitle.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        eventTitle = {
            let label = UILabel()
            label.text = event.title
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: invitesTo.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        checkinButton = {
            let button = UIButton(type: .system)
            button.tintColor = .white
            button.setTitle(CHECK_IN, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.backgroundColor = MAIN_TINT
            button.layer.cornerRadius = 10
            button.titleEdgeInsets.left = 20
            button.titleEdgeInsets.right = 20
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true
            button.heightAnchor.constraint(equalToConstant: 53).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            return button
        }()
        
        captionLabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.textColor = .gray
            label.lineBreakMode = .byWordWrapping
            if event.capacity == 0 {
                label.text = "This check-in form has no capacity limit."
            } else {
                label.text = "Retrieving registrant information..."
            }
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: checkinButton.bottomAnchor, constant: 20).isActive = true
            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -40).isActive = true
            
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
            label.textColor = .init(white: 0.2, alpha: 1)
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: checkbox.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: checkbox.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: checkinButton.topAnchor, constant: -20).isActive = true
            
            label.topAnchor.constraint(greaterThanOrEqualTo: eventTitle.bottomAnchor, constant: 50).isActive = true
            
            return label
        }()
        
        loadingBG = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            v.isHidden = true
            v.layer.cornerRadius = 12
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.widthAnchor.constraint(equalToConstant: 90).isActive = true
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
            label.font = .systemFont(ofSize: 16)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            loadingBG.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        loadLogoImage()
    }
    
    @objc private func check() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func showUI() {
        if orgLogo.image != nil {
            orgLogo.backgroundColor = nil
            if event.capacity != 0 {
                self.captionLabel.text = "\(sheetInfo!.currentOccupied) / \(event.capacity) spots currently filled"
            }
            if event.capacity > 0 && event.capacity <= sheetInfo!.currentOccupied && !sheetInfo!.currentUserCheckedIn {
                self.checkinButton.isUserInteractionEnabled = false
                self.checkinButton.alpha = DISABLED_ALPHA
                self.checkinButton.setTitle(LIST_FULL, for: .normal)
            } else if sheetInfo!.currentUserCheckedIn {
                self.checkinButton.isUserInteractionEnabled = false
                self.checkinButton.alpha = DISABLED_ALPHA
                self.checkinButton.setTitle(CHECKED_IN, for: .normal)
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
                if self.orgLogo.image == nil {
                    self.orgLogo.backgroundColor = nil
                    self.orgLogo.image = UIImage(data: data!) ?? #imageLiteral(resourceName: "unknown")
                }
                self.showUI()
            }
    
        }
        
        task.resume()
    }
    
    @objc private func buttonPressed() {
        switch checkinButton.title(for: .normal) {
        case CHECK_IN:
            sendCheckinRequest()
        default:
            break
        }
    }
    
    private func sendCheckinRequest(code: String? = nil) {
        
        spinnerLabel.text = "Loading..."
        loadingBG.isHidden = false
        
        var parameters: [String: String] = [
            "userId": String(User.current!.uuid),
            "orgId": event.hostID,
            "sheetId": event.uuid,
            "showProfile": checkbox.isChecked ? "1" : "0",
        ]
        
        parameters["code"] = code
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/Checkin",
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
            
            let alert: UIAlertController
            
            switch msg {
            case INTERNAL_ERROR :
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
                return
            case "success":
                DispatchQueue.main.async {
                    self.sheetInfo.currentOccupied += 1
                    self.sheetInfo.currentUserCheckedIn = true
                    self.showUI()
                }
                alert = UIAlertController(title: "Successfully checked in!", message: "You name is now on the list!", preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(.init(title: "View Details", style: .default, handler: { _ in
                    self.parentVC.flipPage()
                }))
            case "full":
                alert = UIAlertController(title: "You're too late!", message: "Unfortunately, the check-in list for this event has already met its capacity of \(self.event.capacity). Please check-in earlier next time!", preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            case "incorrect":
                alert = UIAlertController(title: "Incorrect code", message: "Please confirm your check-in code with the event organizer.", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                }))
            case "wait":
                alert = UIAlertController(title: "Check-in request already sent", message: "You have already initiated a check-in request within the last 3 minutes. Please contact '\(self.event.hostTitle)' for your verification code.", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel))
            case "auth":
                alert = UIAlertController(title: "Enter one-time code to check-in", message: "The event has been configured to require check-in verification. Please contact '\(self.event.hostTitle)' for your 6-digit code.", preferredStyle: .alert)
                
                let proceed = UIAlertAction(title: "Check in", style: .default) {
                    _ in
                    self.authenticateCheckin(code: alert.textFields![0].text ?? "")
                }
                
                alert.addAction(.init(title: "Cancel", style: .cancel))
                alert.addAction(proceed)
                
                alert.addTextField { textfield in
                    textfield.placeholder = "6-digit code"
                    textfield.keyboardType = .numberPad
                    textfield.autocorrectionType = .no
                    textfield.enablesReturnKeyAutomatically = true
                }
            default:
                print(msg!)
                alert = UIAlertController(title: "Unable to check in", message: "An unknown error has occurred.", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel))
            }
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        task.resume()
    }
    
    private func authenticateCheckin(code: String) {
        spinnerLabel.text = "Verifying..."
        loadingBG.isHidden = false
        sendCheckinRequest(code: code)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

