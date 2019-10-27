//
//  EventDetailPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import EventKit

class EventDetailPage: UIViewController {
    
    static let standardAttributes: [NSAttributedString.Key : Any] = {
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 5.0
        pStyle.paragraphSpacing = 12.0
        
        return [
            NSAttributedString.Key.paragraphStyle: pStyle,
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.5),
            NSAttributedString.Key.kern: 0.2
        ]
    }()
    
    /// The event which the current view controller displays.
    var event: Event!
    
    var interestedStatusChanged: ((Bool) -> ())?
    var orgEventView: OrgEventViewController?
    
    private var hideBlankImages = true
    
    private var canvas: UIScrollView!
    private var coverImage: UIImageView!
    private var eventTitle: UILabel!
    private var rightButton: UIBarButtonItem!
    private var goingButton: UIButton!
    private var interestedButton: UIButton!
    
    private var tabStrip: ButtonBarPagerTabStripViewController!
    
    private(set) var invisible: AboutViewController!
    
    var emptyImageHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Event Details"
        view.backgroundColor = AppColors.navbar
        navigationItem.backBarButtonItem = .init(title: "Back", style: .plain, target: nil, action: nil)
                
        if Organization.current == nil {
            rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "heart_empty"), style: .plain, target: self, action: #selector(changedFavoriteStatus))
            rightButton.isEnabled = User.current != nil
            navigationItem.rightBarButtonItem = rightButton
            if User.current?.favoritedEvents.contains(event.uuid) ?? false {
                rightButton.image = #imageLiteral(resourceName: "heart")
            }
        } else if Organization.current?.id == event.hostID {
            rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(moreActions))
            navigationItem.rightBarButtonItem = rightButton
        }

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
        
        
        coverImage = {
            let iv = UIImageView(image: event.eventVisual)
            iv.contentMode = .scaleAspectFill
            iv.backgroundColor = AppColors.mainDisabled
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.topAnchor.constraint(lessThanOrEqualTo: canvas.topAnchor).isActive = true
            iv.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            iv.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 1.5).isActive = true
            
            iv.leftAnchor.constraint(greaterThanOrEqualTo: canvas.leftAnchor).isActive = true
            iv.rightAnchor.constraint(lessThanOrEqualTo: canvas.rightAnchor).isActive = true
            
            let left = iv.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor)
            left.priority = .defaultHigh
            left.isActive = true
            
            let right = iv.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor)
            right.priority = .defaultHigh
            right.isActive = true
            
            if event.eventVisual == nil {
                if event.hasVisual {
                    iv.image = #imageLiteral(resourceName: "cover_placeholder")
                    event.getCover { withImage in
                        iv.image = withImage.eventVisual
                    }
                } else {
                    iv.image = #imageLiteral(resourceName: "berkeley")
                }
            }
            
            iv.isUserInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
            
            return iv
        }()
        
        eventTitle = {
            let label = UILabel()
            label.numberOfLines = 10
            label.text = event.title
            label.font = .systemFont(ofSize: 20, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 25).isActive = true
//            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -300).isActive = true

            return label
        }()
        
        interestedButton = {
            let button = UIButton(type: .system)
            button.tintColor = AppColors.interest
            button.isHidden = Organization.current != nil
            button.isEnabled = User.current != nil
            button.imageView?.contentMode = .scaleAspectFit
            button.tintColor = AppColors.main
            if User.current?.interestedEvents.contains(event.uuid) ?? false {
                button.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                button.setImage(#imageLiteral(resourceName: "star_empty").withRenderingMode(.alwaysTemplate), for: .normal)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.centerYAnchor.constraint(equalTo: eventTitle.centerYAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 35).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: eventTitle.rightAnchor, constant: 15).isActive = true
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            
            button.addTarget(self, action: #selector(interestedAction), for: .touchUpInside)
            
            return button
        }()
        
        
        view.layoutIfNeeded()
        
        tabStrip = {
            
            let vc = AboutViewController(detailPage: self)
            vc.view.isHidden = true
            
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(vc.view)
            vc.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            
            invisible = vc
            
            let tabStrip = EventDetailTabStrip(detailPage: self)
            tabStrip.view.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tabStrip.view)
            
            tabStrip.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabStrip.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tabStrip.view.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 20).isActive = true
            
            tabStrip.view.bottomAnchor.constraint(equalTo: canvas.bottomAnchor).isActive = true
            
            tabStrip.view.heightAnchor.constraint(equalTo: vc.view.heightAnchor, constant: 70).isActive = true
            
            addChild(tabStrip)
            tabStrip.didMove(toParent: self)
            
            return tabStrip
        }()
        
        
        let bottom = UIView()
        bottom.backgroundColor = AppColors.canvas
        bottom.translatesAutoresizingMaskIntoConstraints = false
        canvas.insertSubview(bottom, belowSubview: coverImage)
        
        bottom.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottom.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottom.topAnchor.constraint(equalTo: tabStrip.view.topAnchor).isActive = true
        bottom.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
    }
    
    @objc private func changedFavoriteStatus() {
        
        guard let currentUser = User.current else {
            return
        }
        
        // If the current user exists, then the right button is the favorite button
        
        let isFavoriteOriginally = currentUser.favoritedEvents.contains(event.uuid)
        
        func toggle(_ update: Bool = true) {
            if rightButton.image == #imageLiteral(resourceName: "heart_empty") {
                rightButton.image = #imageLiteral(resourceName: "heart")
            } else {
                rightButton.image = #imageLiteral(resourceName: "heart_empty")
            }
            if update {
                if isFavoriteOriginally {
                    currentUser.favoritedEvents.remove(event.uuid)
                } else {
                    currentUser.favoritedEvents.insert(event.uuid)
                }
            } else {
                if isFavoriteOriginally {
                    currentUser.favoritedEvents.insert(event.uuid)
                } else {
                    currentUser.favoritedEvents.remove(event.uuid)
                }
            }
        }
        
        toggle()
        UISelectionFeedbackGenerator().selectionChanged()
                
        currentUser.syncFavorited(favorited: !isFavoriteOriginally, for: event) { successful in
            guard successful else {
                internetUnavailableError(vc: self)
                return
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eventTitle.text = event.title
        if event.eventVisual != nil {
            emptyImageHeightConstraint?.isActive = false
            coverImage.image = event.eventVisual
        }
        if let v = tabStrip.viewControllers.last as? OtherViewController {
            v.event = self.event
            v.refreshValues()
        }
        
        if let v = tabStrip.viewControllers.first as? AboutViewController {
            v.event = self.event
        }
    }
    
    @objc private func interestedAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        let status: Bool
        
        if User.current!.interestedEvents.contains(event.uuid) {
            interestedButton.setImage(#imageLiteral(resourceName: "star_empty").withRenderingMode(.alwaysTemplate), for: .normal)
            status = false
        } else {
            self.interestedButton.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: .normal)
            status = true
        }
        
        User.current?.syncInterested(interested: status, for: event) { success in
            if !success {
                internetUnavailableError(vc: self)
            }
        }
        
        if let v = tabStrip.viewControllers.last as? OtherViewController {
            v.interestedText.text = String(event.interested.count)
        }
        
        interestedStatusChanged?(status)
        
    }

    @objc private func moreActions() {
        let alert = UIAlertController(title: "Event Actions", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Edit", style: .default, handler: { action in
            self.openEditor()
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = rightButton
        }
        
        if self.event.published {
            alert.addAction(.init(title: "Check-in Info", style: .default, handler: { action in
                let checkin = EventCheckinOverview()
                checkin.event = self.event
                self.navigationController?.pushViewController(checkin, animated: true)
            }))
            if self.event.requiresTicket {
                alert.addAction(.init(title: "Ticket Center", style: .default, handler: { action in
                    let center = TicketCenter(parentVC: self)
                    self.navigationController?.pushViewController(center, animated: true)
                }))
            }
            alert.addAction(.init(title: "Remove Event", style: .destructive) { _ in
                let warning = UIAlertController(title: "Are you sure?", message: "You are about to permanently remove this published event. There is no going back.", preferredStyle: .alert)
                warning.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                warning.addAction(.init(title: "Remove", style: .destructive) { _ in
                    self.removeEvent()
                })
                self.present(warning, animated: true)
            })
            
        } else {
            alert.addAction(.init(title: "Delete Draft", style: .destructive) { _ in
                let warning = UIAlertController(title: "Are you sure?", message: "You are about to delete this local draft. This process cannot be undone.", preferredStyle: .alert)
                warning.addAction(.init(title: "Cancel", style: .cancel))
                warning.addAction(.init(title: "Delete", style: .destructive) { _ in
                    // Delete a local copy
                    EventDraft.removeDraft(uuid: self.event.uuid) { remaining in
                        self.orgEventView?.allDrafts = remaining
                        self.orgEventView?.updateFiltered()
                        self.orgEventView!.eventCatalog.reloadData()
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                self.present(warning, animated: true)
            })
        }
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func openEditor() {
        let editor = EventDraft(event: event.copy(), detailPage: self)
        editor.orgEventView = self.orgEventView
        editor.isEditingExistingEvent = true
        let nav = UINavigationController(rootViewController: editor)
        nav.navigationBar.tintColor = AppColors.main
        nav.navigationBar.barTintColor = AppColors.navbar
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.shadowImage = UIImage()
        present(nav, animated: true)
    }
    
    @objc private func imageTapped() {
        if let cover = event.eventVisual {
            let fullScreen = ImageFullScreenPage(image: cover)
            present(fullScreen, animated: false)
        }
    }
    
    private func removeEvent() {
        
        let parameters = [
            "uuid": event.uuid,
            "orgId": event.hostID
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/RemoveEvent",
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
            
            let msg = String(data: data!, encoding: .utf8)!
            
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                print("Event <\(self.event.title)> was successfully deleted.")
                DispatchQueue.main.async {
                    self.orgEventView?.allEvents.remove(self.event)
                    self.orgEventView?.updateFiltered()
                    self.orgEventView?.eventCatalog.reloadData()
                    self.navigationController?.popViewController(animated: true)
                }
            default:
                print("Server returned message: " + msg)
            }
        }
        
        task.resume()
    }

}
