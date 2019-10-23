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
        
        /* old solution
        tableView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: IndexPath(row: self.groupedMessages[self.groupedMessages.count - 1].content.count - 1, section: self.groupedMessages.count - 1), at: .bottom, animated: false)
        }*/
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
                self.loadingBG.isHidden = false
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
            let cell = NewEventCell(content: msg as! NewEventNotification, parent: self)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        default:
            break
        }
        
        let cell = UnsupportedContentCell(content: msg)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        return cell
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
    
}
