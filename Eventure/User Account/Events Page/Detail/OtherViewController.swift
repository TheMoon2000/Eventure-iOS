//
//  OtherViewController.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class OtherViewController: UIViewController, IndicatorInfoProvider {
    
    var event: Event!
    var detailPage: EventDetailPage!
    
    private var canvas: UIView!
    
    private var hostLabel: UILabel!
    private var hostLink: UIButton!
    
    private var locationLabel: UILabel!
    private(set) var locationText: UILabel!
    
    private var dateLabel: UILabel!
    private(set) var dateText: UILabel!
    
    private var interestedLabel: UILabel!
    private(set) var interestedText: UILabel!
    
    var heightConstraint: NSLayoutConstraint?

    required init(detailPage: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = detailPage.event
        self.detailPage = detailPage
        view.backgroundColor = detailPage.view.backgroundColor
        
        event.fetchHostInfo { org in
            self.hostLink.isUserInteractionEnabled = true
            self.hostLink.setTitleColor(LINK_COLOR, for: .normal)
        }
        
        
        canvas = {
            let canvas = UIView()
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            canvas.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        hostLabel = {
            let label = UILabel()
            label.text = "Host: "
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: canvas.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 35).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        hostLink = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .right
            button.setTitle(event.hostTitle, for: .normal)
            button.setTitleColor(.darkGray, for: .normal)
            button.isUserInteractionEnabled = false
            button.contentHorizontalAlignment = .right
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: hostLabel.rightAnchor, constant: 15).isActive = true
            button.rightAnchor.constraint(equalTo: canvas.rightAnchor, constant: -30).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: hostLabel.topAnchor).isActive = true
            
            button.addTarget(self, action: #selector(openOrganization), for: .touchUpInside)
            
            return button
        }()
        
        
        locationLabel = {
            let label = UILabel()
            label.text = "Location: "
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: hostLink.titleLabel!.bottomAnchor, constant: 15).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        locationText = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.text = event.location.isEmpty ? "TBA" : event.location
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: locationLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: locationLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: hostLink.titleLabel!.rightAnchor).isActive = true
            
            return label
        }()
        
        
        dateLabel = {
            let label = UILabel()
            label.text = "Start time: "
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: locationText.bottomAnchor, constant: 15).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        dateText = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.text = event.startTime?.readableString()
            if (label.text?.isEmpty ?? true) { label.text = "Unspecified" }
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: locationText.rightAnchor).isActive = true
            
            return label
        }()
        
        
        interestedLabel = {
            let label = UILabel()
            label.text = "Interested: "
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: dateLabel.bottomAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: dateText.bottomAnchor, constant: 15).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        interestedText = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.text = String(event.interested.count)
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: interestedLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: interestedLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: dateText.rightAnchor).isActive = true
            
            return label
        }()
        
        interestedText.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func openOrganization() {
        if let org = event.hostInfo {
            let info = OrgDetailPage(organization: org)
            info.hidesBottomBarWhenPushed = true
            detailPage.navigationController?.pushViewController(info, animated: true)
        } else {
            let alert = UIAlertController(title: "Organization info is still loading", message: "We are yet to fetch the information for the host organization \"\(event.hostTitle)\". Please try again later.", preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .cancel))
            detailPage.present(alert, animated: true)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if heightConstraint == nil {
            heightConstraint = detailPage.invisible.view.heightAnchor.constraint(greaterThanOrEqualToConstant: canvas.preferredHeight(width: view.frame.width))
        } else {
            heightConstraint?.constant = canvas.preferredHeight(width: view.frame.width)
        }
        heightConstraint?.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        heightConstraint?.isActive = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.heightConstraint?.constant = self.canvas.preferredHeight(width: size.width)
        }, completion: nil)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Detail")
    }
    
}
