//
//  ArchivedAnnouncements.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/16.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class ArchivedAnnouncements: UIViewController {
    
    private var announcements: [Announcement]?
    private var updater: ((UITraitCollection) -> ())?
    
    private var failPage: UIView!
    private var loadingBG: UIVisualEffectView!
    private var messageTable: UITableView!
    private var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Past Announcements"
        view.backgroundColor = AppColors.tableBG
        
        setup()
        fetchAnnouncements()
    }
    
    private func setup() {
        messageTable = {
            let tv = UITableView()
            tv.delegate = self
            tv.dataSource = self
            tv.tableFooterView = UIView()
            tv.backgroundColor = .clear
            tv.register(AnnouncementHistoryCell.self, forCellReuseIdentifier: "cell")
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
        
        (failPage, updater) = view.addConnectionNotice {
            self.fetchAnnouncements()
        }
        failPage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        failPage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -MainTabBarController.current.tabBar.bounds.height / 2).isActive = true
        
        loadingBG = view.addLoader()
        
        emptyLabel = view.addCenteredLabel()
    }
    
    private func fetchAnnouncements() {
        
        loadingBG.isHidden = false
        emptyLabel.text = ""
        
        var parameters = [String: String]()
        parameters["email"] = User.current?.email
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetAnnouncementHistory",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.loadingBG.isHidden = true
                    self.failPage.isHidden = false
                }
                return
            }
            
            if let json = try? JSON(data: data!).arrayValue {
                var tmp = [Announcement]()
                for aData in json {
                    tmp.append(Announcement(json: aData))
                }
                
                self.announcements = tmp.sorted(by: { a1, a2 in
                    a1.publishedDate > a2.publishedDate
                })
                DispatchQueue.main.async {
                    self.loadingBG.isHidden = true
                    if tmp.isEmpty {
                        self.emptyLabel.text = "No past announcements."
                    } else {
                        self.messageTable.reloadData()
                    }
                }
            } else {
                print("WARNING: error parsing announcement history!")
            }
        }
        
        task.resume()
    }
    
}


extension ArchivedAnnouncements: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AnnouncementHistoryCell
        
        let a = announcements![indexPath.row]
        
        cell.setTitle(title: a.title, sender: a.sender)
        cell.dateLabel.text = a.publishedDate.elapsedTimeDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = AnnouncementContent(announcements![indexPath.row], fromHistory: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
