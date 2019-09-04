//
//  OrgDetailPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftyJSON

class OrgDetailPage: UIViewController {
    
    var organization: Organization!
    
    private var previewContainer: UIView!
    private var thumbNail: UIImageView!
    
    private var textStack: UIStackView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    private var expandButton: UIButton!
    private var disclosureIndicator: UIImageView!
    
    private var tabStrip: ButtonBarPagerTabStripViewController!
    private var tabTopConstraint: NSLayoutConstraint!
    
    required init(organization: Organization) {
        super.init(nibName: nil, bundle: nil)
        
        self.organization = organization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        
        var favImage = #imageLiteral(resourceName: "heart_empty")
        if User.current != nil && organization.subscribers.contains(User.current!.uuid) {
            favImage = #imageLiteral(resourceName: "heart")
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favImage, style: .plain, target: self, action: #selector(subscribe(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = User.current != nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Overview", style: .plain, target: nil, action: nil)
        
        view.layoutIfNeeded()
        
        if view.frame.height < 450 {
            self.title = organization.title
            self.navigationController?.navigationBar.setNeedsDisplay()
        }
        
        previewContainer = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            v.heightAnchor.constraint(equalToConstant: 90).isActive = true
            
            return v
        }()
        
        thumbNail = {
            let thumbNail = UIImageView(image: organization.logoImage)
            
            if organization.logoImage == nil {
                organization.getLogoImage { orgWithImage in
                    self.thumbNail.image = orgWithImage.logoImage
                }
            }
            
            thumbNail.contentMode = .scaleAspectFit
            if thumbNail.image == nil {
                // TODO: Replace with default logo image
                thumbNail.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            }
            thumbNail.tintColor = MAIN_DISABLED
            thumbNail.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(thumbNail)
            
            thumbNail.widthAnchor.constraint(equalToConstant: 60).isActive = true
            thumbNail.heightAnchor.constraint(equalTo: thumbNail.widthAnchor).isActive = true
            thumbNail.leftAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            thumbNail.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor).isActive = true
            
            return thumbNail
        }()
        
        disclosureIndicator = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "disclosure"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 22).isActive = true
            iv.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            return iv
        }()
        
        
        textStack = {
            
            titleLabel = {
                let label = UILabel()
                label.numberOfLines = 2
                label.text = organization.title
                label.font = .systemFont(ofSize: 18, weight: .semibold)
                label.translatesAutoresizingMaskIntoConstraints = false
                
                return label
            }()
            
            descriptionLabel = {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16.5)
                label.textColor = .lightGray
                label.text = "Loading member info..."
                label.text = "Active Members: \(organization.members.count)"
                label.textColor = .gray

                label.translatesAutoresizingMaskIntoConstraints = false
                
                return label
            }()
            
            let sv = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
            sv.axis = .vertical
            sv.alignment = .fill
            sv.spacing = 5
            sv.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: thumbNail.rightAnchor, constant: 20).isActive = true
            sv.rightAnchor.constraint(equalTo: disclosureIndicator.leftAnchor, constant: -15).isActive = true
            sv.centerYAnchor.constraint(equalTo: previewContainer.centerYAnchor).isActive = true
            
            return sv
        }()
        
        expandButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            previewContainer.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: previewContainer.safeAreaLayoutGuide.rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: previewContainer.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
            button.addTarget(self, action: #selector(buttonLifted), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
            button.addTarget(self, action: #selector(buttonTriggered), for: .touchUpInside)
            
            return button
        }()
        
        tabStrip = {
            let tabStrip = OrgEventsTabStrip()
            tabStrip.detailPage = self
            tabStrip.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tabStrip.view)
            
            tabStrip.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabStrip.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            if view.frame.height > 450 {
                tabTopConstraint = tabStrip.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
            } else {
                tabTopConstraint = tabStrip.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            }
            tabTopConstraint.isActive = true

            tabStrip.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            addChild(tabStrip)
            tabStrip.didMove(toParent: self)
            
            return tabStrip
        }()
    }
    
    @objc private func subscribe(_ sender: UIBarButtonItem) {
        
        guard let currentUser = User.current else {
            let alert = UIAlertController(title: "You are not logged in", message: "Add to favorites is only available to registered users.", preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        let alreadySubscribed = organization.subscribers.contains(currentUser.uuid)
        
        func toggle(_ update: Bool = true) {
            
            var newStatus: Bool
            
            if update && !alreadySubscribed || !update && alreadySubscribed {
                newStatus = true
                currentUser.subscriptions.insert(organization.id)
                organization.subscribers.insert(currentUser.uuid)
            } else {
                newStatus = false
                currentUser.subscriptions.remove(organization.id)
                organization.subscribers.remove(currentUser.uuid)
            }
            sender.image = newStatus ? #imageLiteral(resourceName: "heart") : #imageLiteral(resourceName: "heart_empty")
        }
        
        toggle()
        
        let parameters = [
            "userId": String(User.current!.uuid),
            "orgId": organization.id,
            "subscribed": sender.image == #imageLiteral(resourceName: "heart") ? "1" : "0"
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/MarkOrganization",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) {
                        toggle(false) // Toggle back to the original state
                    }
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8) ?? INTERNAL_ERROR
            if msg == INTERNAL_ERROR {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) {
                        toggle(false) // Toggle back to the original state
                    }
                }
            } else if msg != "success" {
                DispatchQueue.main.async {
                    toggle(false)
                }
            }
        }
        
        task.resume()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            if size.height >= 450 {
                self.tabTopConstraint.constant = 100
                self.title = nil
                self.previewContainer.isHidden = false
            } else {
                self.tabTopConstraint.constant = 0
                self.title = self.organization.title
                self.previewContainer.isHidden = true
            }
            self.navigationController?.navigationBar.setNeedsDisplay()
        }, completion: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Extension for button event handlers
extension OrgDetailPage {
    
    @objc private func buttonPressed() {
        disclosureIndicator.image = #imageLiteral(resourceName: "disclosure_pressed")
        previewContainer.backgroundColor = .init(white: 0.93, alpha: 1)
    }
    
    @objc private func buttonLifted() {
        disclosureIndicator.image = #imageLiteral(resourceName: "disclosure")
        previewContainer.backgroundColor = nil
    }
    
    @objc private func buttonTriggered() {
        let infoPage = OrgInfoPage()
        infoPage.detailPage = self
        infoPage.organization = organization!
        navigationController?.pushViewController(infoPage, animated: true)
    }
    
}


