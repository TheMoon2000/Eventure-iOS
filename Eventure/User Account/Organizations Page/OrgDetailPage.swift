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
    
    var orgOverview: OrganizationsViewController.OrgOverview!
    private(set) var organization: Organization? {
        didSet {
            DispatchQueue.main.async {
                self.expandButton.isEnabled = self.organization != nil
            }
        }
    }
    
    private var previewContainer: UIView!
    private var thumbNail: UIImageView!
    
    private var textStack: UIStackView!
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    private var expandButton: UIButton!
    private var disclosureIndicator: UIImageView!
    
    private var tabStrip: ButtonBarPagerTabStripViewController!
    private var tabTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let favImage = orgOverview.subscribed ? #imageLiteral(resourceName: "heart") : #imageLiteral(resourceName: "heart_empty")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favImage, style: .plain, target: self, action: #selector(favorite(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = User.current != nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Overview", style: .plain, target: nil, action: nil)
        
        view.layoutIfNeeded()
        
        if view.frame.height < 450 {
            self.title = orgOverview.title
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
            let thumbNail = UIImageView(image: orgOverview.logoImage)
            thumbNail.contentMode = .scaleAspectFit
            if thumbNail.image == nil {
                // TODO: Replace with default logo image
                thumbNail.backgroundColor = LINE_TINT
            }
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
                label.text = orgOverview.title
                label.font = .systemFont(ofSize: 18, weight: .semibold)
                label.translatesAutoresizingMaskIntoConstraints = false
                
                return label
            }()
            
            descriptionLabel = {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16.5)
                label.textColor = .lightGray
                label.text = "Loading member info..."
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
            button.isEnabled = false
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
        
        loadOrganizationInfo()
        getLogoImage(for: orgOverview)
    }
    
    @objc private func favorite(_ sender: UIBarButtonItem) {
        
        guard User.current != nil else {
            let alert = UIAlertController(title: "You are not logged in", message: "Add to favorites is only available to registered users.", preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        var parameters = ["userId": String(User.current!.uuid)]
        
        if sender.image == #imageLiteral(resourceName: "heart_empty") {
            sender.image = #imageLiteral(resourceName: "heart")
            parameters["isFavorited"] = "1"
        } else {
            sender.image = #imageLiteral(resourceName: "heart_empty")
            parameters["isFavorited"] = "0"
        }
    }
    
    private func loadOrganizationInfo() {
        
        var parameters = ["orgId": orgOverview.id]
        parameters["userId"] = User.current?.uuid.description
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/GetOrgInfo",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
            
            if let orgInfo = try? JSON(data: data!) {
                
                self.organization = Organization(orgInfo: orgInfo)
                self.organization?.logoImage = self.orgOverview.logoImage
                let infoPage = OrgInfoPage()
                infoPage.organization = self.organization!
                
                DispatchQueue.main.async {
                    self.descriptionLabel.text = "Active Members: \(self.organization!.members.count)"
                    self.descriptionLabel.textColor = .gray
                }
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    /// Load the logo image for an organization.
    private func getLogoImage(for org: OrganizationsViewController.OrgOverview) {
        if !org.hasLogo { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": org.id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            DispatchQueue.main.async {
                self.thumbNail.image = UIImage(data: data!)
                self.thumbNail.backgroundColor = self.thumbNail.image == nil ? LINE_TINT : nil
                self.orgOverview.logoImage = self.thumbNail.image
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
                self.title = self.orgOverview.title
                self.previewContainer.isHidden = true
            }
            self.navigationController?.navigationBar.setNeedsDisplay()
        }, completion: nil)
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


