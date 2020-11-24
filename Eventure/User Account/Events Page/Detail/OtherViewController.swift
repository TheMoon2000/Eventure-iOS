//
//  OtherViewController.swift
//  Eventure
//
//  Created by appa on 8/23/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MapKit
import CoreLocation

class OtherViewController: UIViewController, IndicatorInfoProvider {
    
    var event: Event!
    var detailPage: EventDetailPage!
    
    private var verticalSpacing: CGFloat = 15
    
    private var canvas: UIView!
    
    private var hostLabel: UILabel!
    private var hostLink: UIButton!
    
    private var locationLabel: UILabel!
    private(set) var locationText: UIButton!
    
    private var startLabel: UILabel!
    private(set) var startDate: UILabel!
    
    private var endLabel: UILabel!
    private(set) var endDate: UILabel!
    
    private var interestedLabel: UILabel!
    private(set) var interestedText: UILabel!
    
    private var ticketLabel: UILabel!
    private(set) var ticketValue: UIButton!
        
    var heightConstraint: NSLayoutConstraint?

    required init(detailPage: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = detailPage.event
        self.detailPage = detailPage
        view.backgroundColor = AppColors.canvas
        
        event.fetchHostInfo { org in
            self.hostLink.isUserInteractionEnabled = true
            self.hostLink.setTitleColor(AppColors.link, for: .normal)
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
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
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
            button.titleLabel?.font = .appFontMedium(17)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .right
            button.setTitle(event.hostTitle, for: .normal)
            button.setTitleColor(AppColors.value, for: .normal)
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
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: hostLink.titleLabel!.bottomAnchor, constant: verticalSpacing).isActive = true
            
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        locationText = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .appFontRegular(17)
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 0
            button.setTitleColor(AppColors.value, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.titleLabel?.leftAnchor.constraint(equalTo: locationLabel.rightAnchor, constant: 10).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: locationLabel.topAnchor).isActive = true
            button.titleLabel?.rightAnchor.constraint(equalTo: hostLink.titleLabel!.rightAnchor).isActive = true
            
            button.addTarget(self, action: #selector(openLocation(_:)), for: .touchUpInside)
            
            return button
        }()
        
        startLabel = {
            let label = UILabel()
            label.text = "Start time: "
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: locationText.titleLabel!.bottomAnchor, constant: verticalSpacing).isActive = true
            
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        startDate = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.font = .appFontRegular(17)
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: startLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: startLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: canvas.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        endLabel = {
            let label = UILabel()
            label.text = "Duration: "
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: startDate.bottomAnchor, constant: verticalSpacing).isActive = true
            
            label.setContentCompressionResistancePriority(.required, for: .horizontal)

            return label
        }()
        
        endDate = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.font = .appFontRegular(17)
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: endLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: endLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: canvas.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        
        interestedLabel = {
            let label = UILabel()
            label.text = "Interested: "
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: endDate.bottomAnchor, constant: verticalSpacing).isActive = true
            
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        interestedText = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 0
            label.font = .appFontRegular(17)
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: interestedLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: interestedLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: canvas.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
        ticketLabel = {
            let label = UILabel()
            label.textColor = AppColors.value
            label.font = .appFontSemibold(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: interestedText.bottomAnchor, constant: verticalSpacing).isActive = true
            
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        ticketValue = {
            let button = UIButton(type: .system)
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 0
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.titleLabel?.leftAnchor.constraint(equalTo: ticketLabel.rightAnchor, constant: 10).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: ticketLabel.topAnchor).isActive = true
            button.titleLabel?.rightAnchor.constraint(equalTo: canvas.rightAnchor, constant: -30).isActive = true
            
            return button
        }()
        
        let b = ticketValue.titleLabel?.bottomAnchor.constraint(lessThanOrEqualTo: canvas.bottomAnchor, constant: -20)
        b?.priority = .defaultHigh
        b?.isActive = true
        
        refreshValues()
    }
    
    func refreshValues() {
        locationText.setTitle(event.location.isEmpty ? "TBA" : event.location, for: .normal) 
        startDate.text = event.startTime?.readableString() ?? "Unspecified"
        endDate.text = event.duration
        interestedText.text = String(event.interested.count)
        ticketValue.titleLabel?.font = .appFontRegular(17)
        if User.current != nil {
            ticketLabel.text = "Tickets:"
            if event.requiresTicket {
                ticketValue.setTitleColor(AppColors.link, for: .normal)
                ticketValue.addTarget(self, action: #selector(showTickets), for: .touchUpInside)
                ticketValue.setTitle("Buy Tickets", for: .normal)
            } else {
                ticketValue.isUserInteractionEnabled = false
                ticketValue.setTitleColor(AppColors.value, for: .normal)
                ticketValue.setTitle("No tickets required", for: .normal)
            }
        } else {
            ticketLabel.text = "Requires tickets:"
            ticketValue.isUserInteractionEnabled = false
            ticketValue.setTitleColor(AppColors.value, for: .normal)
            ticketValue.setTitle(event.requiresTicket ? "Yes" : "No", for: .normal)
        }
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
    
    @objc private func openLocation(_ sender: UIButton) {
        guard let location = sender.title(for: .normal) else { return }
        guard location != "TBA" else { return }
        
        NetworkStatus.addTask()
        
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            
            print(placemarks as Any, error as Any)
            
            NetworkStatus.removeTask()
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Open location in maps?", message: "Maps can attempt to look up the location of this event.", preferredStyle: .actionSheet)
                alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(.init(title: "Open in Maps", style: .default, handler: { _ in
                    let mapItem = MKMapItem(placemark: .init(placemark: placemark))
                    mapItem.name = location
                    mapItem.openInMaps(launchOptions: nil)
                }))
                
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = sender
                    popoverController.sourceRect = sender.frame
                }
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc private func showTickets() {
        let bt = BuyTickets(parentVC: detailPage)
        navigationController?.pushViewController(bt, animated: true)
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
