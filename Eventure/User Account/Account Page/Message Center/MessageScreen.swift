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
            tv.tableHeaderView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 10))
            tv.tableFooterView = .init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 1))
            tv.contentInset.bottom = 5
            tv.sectionFooterHeight = 10
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
        
        tableView.layoutIfNeeded()
        tableView.scrollToRow(at: [groupedMessages.count - 1, groupedMessages.last!.content.count - 1], at: .bottom, animated: false)
    }
    
    private func groupByDate() {
        guard let sorted = AccountNotification.current[sender] else { return }
        
        var tmp = [(String, [AccountNotification])]()
        var lastDate = Date.distantPast
        
        for msg in sorted {
            msg.read = true
            if tmp.isEmpty || msg.creationDate.timeIntervalSince(lastDate) >= 300 {
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
        return groupedMessages.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MessageDateHeaderView()
        header.headerTitle.text = groupedMessages[section].dateTime
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedMessages[section].content.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = groupedMessages[indexPath.section].content[indexPath.row]
        
        switch msg.type {
        case .membershipInvite:
            let cell = MembershipInvitationCell(invitation: msg as! InviteNotification)
            
            cell.acceptHandler = { accepted in
                self.loadingBG.isHidden = false
            }
             return cell
        case .plain:
            return PlainMessageCell(content: msg)
        case .eventUpdate:
            return EventUpdateCell(content: msg as! EventUpdateNotification,
                                   parent: self)
        case .newEvent:
            return NewEventCell(content: msg as! NewEventNotification, parent: self)
        default:
            break
        }
        
        return UnsupportedContentCell(content: msg)
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
