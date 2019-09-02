//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinOverview: UIViewController {
    
    private var event: Event!
    
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    private var invitesTo: UILabel!
    private var eventTitle: UILabel!
    private var checkinButton: UIButton!
    
    private var checkbox: UICheckbox!
    private var checkboxLabel: UILabel!
    private var consentStack: UIStackView!
    
    private var blocker: UIView!
    private var spinner: UIActivityIndicatorView!
    
    required init(event: Event!) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        loadLogoImage()
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
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
            button.widthAnchor.constraint(equalToConstant: 215).isActive = true
            button.heightAnchor.constraint(equalToConstant: 53).isActive = true
            
            return button
        }()
        
        checkbox = {
            let check = UICheckbox()
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
            label.bottomAnchor.constraint(equalTo: checkinButton.topAnchor, constant: -25).isActive = true
            
            
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
    
    private func loadLogoImage() {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": event.hostID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.blocker.isHidden = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
                return
            }
            
            DispatchQueue.main.async {
                self.orgLogo.image = UIImage(data: data!) ?? #imageLiteral(resourceName: "unknown")
            }
        }
        
        task.resume()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}

