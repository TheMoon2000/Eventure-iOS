//
//  MessageScreen.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageScreen: UIViewController {
    
    private var parentVC: MessageCenter!
    private var sender: AccountNotification.Sender!
    private var groupedMessages = [(dateTime: String, content: [AccountNotification])]()
    
    private var tableView: UITableView!
    private var loadingBG: UIView!
    private var orgInfo: Organization?
    
    private(set) var datesDisplayed = 10
    private var shouldLoadMore = false
    private var needsResetBottomInset = false
    
    required init(parent: MessageCenter, sender: AccountNotification.Sender) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parent
        self.sender = sender
        self.title = sender.name
        self.view.backgroundColor = AppColors.canvas
        
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        return [UIPreviewAction(title: "Mark as Unread", style: .default, handler: { action, controller in
            self.groupedMessages.first?.content.first?.read = false
            AccountNotification.save()
            self.parentVC.tableView.reloadData()
            self.parentVC.refreshNavBarTitle()
        })]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = {
            let tv = UITableView(frame: .zero, style: .grouped)
            tv.tableHeaderView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 2))
            tv.tableFooterView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 15))
            tv.contentInset.bottom = 5
            tv.sectionFooterHeight = 2
            tv.separatorStyle = .none
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.dataSource = self
            (tv as UIScrollView).delegate = self
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
                
        navigationItem.backBarButtonItem = .init(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(more))
        
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
                
        groupByDate()
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        navigationController?.navigationBar.shadowImage = nil
        
        view.layoutIfNeeded()
        adjustInsets()
    }
    
    private func adjustInsets() {
        
        let contentHeight: CGFloat
        
        if #available(iOS 13.0, *) {
            contentHeight = tableView.bounds.height
        } else {
            contentHeight = tableView.bounds.height
            + view.frame.minY
            - (navigationController?.navigationBar.frame.height ?? 0)
            - UIApplication.shared.statusBarFrame.height
        }
        
        let offset = max(0, contentHeight - tableView.contentSize.height)
        tableView.contentInset.top = offset
        tableView.contentInset.bottom = -offset
        
        if tableView.contentOffset.y == 0 {
            tableView.setContentOffset(.init(x: 0, y: 2), animated: false)
        }
    }
    
    private func groupByDate() {
        guard let sorted = AccountNotification.current[sender] else { return }
        
        var tmp = [(String, [AccountNotification])]()
        var lastDate = Date.distantFuture
        
        for msg in sorted.reversed() {
            msg.read = true
            if tmp.isEmpty || lastDate.timeIntervalSince(msg.creationDate) >= 300 {
                tmp.append((msg.creationDate.mediumString, [msg]))
            } else {
                tmp[tmp.count - 1].1.append(msg)
            }
            lastDate = msg.creationDate
        }
        
        groupedMessages = tmp
        parentVC.refreshNavBarTitle()
        getOrgDetails()
    }
    
    private func getOrgDetails() {
        
        Organization.getOrganization(with: sender.senderID) { orgInfo in
            if orgInfo != nil {
                self.orgInfo = orgInfo
                self.orgInfo?.logoImage = AccountNotification.cachedLogos[orgInfo!.id]
            }
        }
        
    }
    
    
    @objc private func more() {
        
        let alert = UIAlertController()
        alert.addAction(.init(title: "Cancel", style: .cancel))
        if sender.senderID == AccountNotification.SYSTEM_ID {
            alert.addAction(.init(title: "About Eventure", style: .default, handler: { _ in
                let aboutPage = AboutPage()
                self.navigationController?.pushViewController(aboutPage, animated: true)
            }))
        } else {
            alert.addAction(.init(title: "View Organization", style: .default, handler: { _ in
                if let org = self.orgInfo {
                    let orgDetails = OrgDetailPage(organization: org)
                    self.navigationController?.pushViewController(orgDetails, animated: true)
                }
            }))
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension MessageScreen: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return min(datesDisplayed, groupedMessages.count) + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 { return nil }
        
        let header = MessageDateHeaderView()
        header.headerTitle.text = groupedMessages[section - 1].dateTime
        header.transform = CGAffineTransform(scaleX: 1, y: -1)
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == groupedMessages.count { return 0 }
        return groupedMessages[section].content.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let header = self.tableView(tableView, viewForHeaderInSection: section)
        return (header?.preferredHeight(width: tableView.bounds.width) ?? 10)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        return cell.preferredHeight(width: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = groupedMessages[indexPath.section].content[indexPath.row]
        
        switch msg.contentType {
        case .membershipInvite:
            let cell = MembershipInvitationCell(invitation: msg as! InviteNotification)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.acceptHandler = { accepted in
                
                let alert: UIAlertController
                if accepted {
                    alert = UIAlertController(title: "Accept Membership?", message: "Once you accepted the invitation, you will be considered part as part of the club.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Accept", style: .default, handler: { _ in
                        self.acceptMembership(accept: true, indexPath: indexPath, content: msg as! InviteNotification)
                    }))
                } else {
                    alert = UIAlertController(title: "Decline Membership?", message: "The club will be notified. You cannot undo this action.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Decline", style: .destructive, handler: { _ in
                        self.acceptMembership(accept: false, indexPath: indexPath, content: msg as! InviteNotification)
                    }))
                }
                alert.addAction(.init(title: "Cancel", style: .cancel))

                self.present(alert, animated: true)
            }
            return cell
        case .plain:
            let cell = PlainMessageCell(content: msg)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case .eventUpdate:
            let cell = EventUpdateCell(content: msg as! EventUpdateNotification,
                                   parent: self)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case .newEvent:
            let cell = NewEventCell(content: msg as! NewEventNotification)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case .newTicket:
            let cell = TicketNotificationCell(content: msg as! TicketNotification,
                                              parent: self)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        default:
            break
        }
        
        let cell = UnsupportedContentCell(content: msg)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let msg = groupedMessages[indexPath.section].content[indexPath.row]

        if let msg = msg as? NewEventNotification {
            openEvent(eventID: msg.eventID)
        }
    }
    
    func openEvent(eventID: String) {
        
        if !loadingBG.isHidden { return }
        
        loadingBG.isHidden = false
        
        var parameters = [String : String]()
        parameters["uuid"] = eventID
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent",
                           parameters: ["uuid": eventID])!
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
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            if let eventDictionary = try? JSON(data: data!) {
                let event = Event(eventInfo: eventDictionary)
                event.eventVisual = AccountNotification.cachedLogos[event.uuid]

                DispatchQueue.main.async {
                    let detailPage = EventDetailPage()
                    detailPage.hidesBottomBarWhenPushed = true
                    detailPage.event = event
                    self.navigationController?.pushViewController(detailPage, animated: true)
                }
                
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Event Not Found", message: "The event you were looking for appears to have been deleted by its organizer.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true)
                    
                }
            }
        }
        
        task.resume()
    }
    
    private func acceptMembership(accept: Bool, indexPath: IndexPath, content: InviteNotification) {
        
        loadingBG.isHidden = false
        
        let parameters = [
            "orgId": sender.senderID,
            "email": User.current!.email,
            "accept": accept ? "1" : "0"
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "account/RespondToInvitation",
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
            switch msg {
            case INTERNAL_ERROR:
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self)
                }
            case "success":
                content.status = accept ? .accepted : .declined
                content.pushStatus()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            default:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
        
        task.resume()
    }
    
}


extension MessageScreen: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        needsResetBottomInset = false
        shouldLoadMore = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let scrolled = scrollView.safeAreaLayoutGuide.layoutFrame.height + scrollView.contentOffset.y
        if height <= scrollView.safeAreaLayoutGuide.layoutFrame.height { return }
                
        if scrolled - height >= -10 && datesDisplayed < groupedMessages.count && shouldLoadMore {
            datesDisplayed += 10
            shouldLoadMore = false
            /*UIView.performWithoutAnimation {
                let currentSections = tableView.numberOfSections - 1
                let newSections = min(groupedMessages.count, datesDisplayed)
                tableView.beginUpdates()
                tableView.deleteSections([tableView.numberOfSections - 1], with: .automatic)
                tableView.insertSections(IndexSet(integersIn: currentSections...newSections), with: .automatic)
                tableView.endUpdates()
            }*/
            
            self.tableView.reloadData()
//            self.adjustInsets()
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
                
        scrollView.setContentOffset(CGPoint(x: 0,y: max(0, scrollView.contentSize.height - scrollView.bounds.height)), animated: true)
        
        return false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if tableView.bounds.height >= tableView.contentSize.height { return }
        
        scrollView.setContentOffset(.init(x: 0, y: max(scrollView.contentOffset.y, 1)), animated: true)
                
        if decelerate {
            needsResetBottomInset = true
        }
    }
    
    
    /*
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if needsResetBottomInset {
            scrollView.setContentOffset(.init(x: 0, y: max(scrollView.contentOffset.y, 1)), animated: true)
            needsResetBottomInset = false
        }
    }*/
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.adjustInsets()
        }, completion: nil)
        
    }
}
