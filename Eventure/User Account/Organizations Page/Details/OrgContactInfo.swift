//
//  OrgContactInfo.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SafariServices

class OrgContactInfo: UIViewController, IndicatorInfoProvider {
    
    private var organization: Organization!
    private let verticalSpacing: CGFloat = 16
    
    private var canvas: UIScrollView!
    
    private var websiteLabel: UILabel!
    private var websiteLink: UIButton!
    private var contactNameLabel: UILabel!
    private var contactNameText: UILabel!
    private var contactEmailLabel: UILabel!
    private var contactEmailLink: UIButton!
    
    required init(organization: Organization) {
        super.init(nibName: nil, bundle: nil)
        
        self.organization = organization
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas
        
        canvas = {
            let sv = UIScrollView()
            sv.alwaysBounceVertical = true
            sv.contentInsetAdjustmentBehavior = .always
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            sv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return sv
        }()
        
        websiteLabel = {
            let label = UILabel()
            label.text = "Website: "
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 35).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        websiteLink = {
            let button = UIButton(type: .system)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .right
            if organization.website.isEmpty {
                button.setTitle("Unavailable", for: .normal)
                button.isUserInteractionEnabled = false
                button.setTitleColor(AppColors.value, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 17)
            } else {
                button.setTitle(organization.website, for: .normal)
                button.setTitleColor(AppColors.link, for: .normal)
                button.contentHorizontalAlignment = .right
                button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: websiteLabel.rightAnchor, constant: 15).isActive = true
            button.titleLabel?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: websiteLabel.topAnchor).isActive = true
            
            button.addTarget(self, action: #selector(loadWebsite), for: .touchUpInside)
            
            return button
        }()
        
        contactNameLabel = {
            let label = UILabel()
            label.text = "Primary Contact:"
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: websiteLabel.leftAnchor).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        contactNameText = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 5
            label.textColor = AppColors.value
            label.text = organization.contactName
            if label.text!.isEmpty { label.text = "None" }
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: contactNameLabel.rightAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: websiteLink.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: contactNameLabel.topAnchor).isActive = true
            label.topAnchor.constraint(equalTo: websiteLink.titleLabel!.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        contactEmailLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.text = "Email:"
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: websiteLabel.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: contactNameText.bottomAnchor, constant: verticalSpacing).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        contactEmailLink = {
            let button = UIButton(type: .system)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .right
            button.setTitle(organization.contactEmail, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            button.setTitleColor(AppColors.link, for: .normal)
            button.contentHorizontalAlignment = .right
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: contactEmailLabel.rightAnchor, constant: 15).isActive = true
            button.rightAnchor.constraint(equalTo: websiteLink.rightAnchor).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: contactEmailLabel.topAnchor).isActive = true
            
            button.addTarget(self, action: #selector(openEmail), for: .touchUpInside)
            
            return button
        }()
    }
    
    @objc private func loadWebsite() {
        var link = organization.website.lowercased()
        if !link.hasPrefix("http://") && !link.hasPrefix("https://") {
            link = "https://" + link
        }
        if let url = URL(string: link) {
            let vc = SFSafariViewController(url: url)
            vc.preferredControlTintColor = AppColors.main
            present(vc, animated: true, completion: nil)
        } else {
            print(organization.website + " cannot be opened")
        }
    }
    
    @objc private func openEmail() {
        if let url = URL(string: "mailto:" + organization.contactEmail) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Unable to open contact email '\(organization.contactEmail)'")
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Contact Info")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
