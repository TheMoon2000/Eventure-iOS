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
    
    
    required init(parent: MessageCenter, sender: AccountNotification.Sender) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parent
        self.sender = sender
        self.title = sender.name
        self.view.backgroundColor = AppColors.canvas
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = {
            let tv = UITableView(frame: .zero, style: .grouped)
            tv.tableHeaderView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 5))
            tv.tableFooterView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 10))
            tv.contentInset.bottom = 5
            tv.sectionFooterHeight = 2
            tv.separatorStyle = .none
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.dataSource = self
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
        
        view.layoutIfNeeded()
        adjustInsets()
    }
    
    private func adjustInsets() {
        let offset = max(0, tableView.bounds.height - tableView.contentSize.height)
        tableView.contentInset.top = offset
        tableView.contentInset.bottom = -offset
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
    }
    
    @objc private func more() {
        
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension MessageScreen: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedMessages.count + 1
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = groupedMessages[indexPath.section].content[indexPath.row]
        
        switch msg.type {
        case .membershipInvite:
            let cell = MembershipInvitationCell(invitation: msg as! InviteNotification)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.acceptHandler = { accepted in
                
                let alert: UIAlertController
                if accepted {
                    alert = UIAlertController(title: "Accept Membership?", message: "Once you accepted the invitation, you will be considered part as part of the club.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Accept", style: .default, handler: { _ in
                        self.acceptMembership(accept: true, content: msg as! InviteNotification)
                    }))
                } else {
                    alert = UIAlertController(title: "Decline Membership?", message: "The club will be notified. You cannot undo this action.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Decline", style: .destructive, handler: { _ in
                        self.acceptMembership(accept: false, content: msg as! InviteNotification)
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
            }
        }
        
        task.resume()
    }
    
    private func acceptMembership(accept: Bool, content: InviteNotification) {
        
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
