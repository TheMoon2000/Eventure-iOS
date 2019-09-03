//
//  CheckinTable.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckinTable: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    
    private var event: Event!
    private var sheetInfo: SignupSheet!
    private var banner: UIVisualEffectView!
    
    private var emptyLabel: UILabel!
    
    private var checkinTitle: UILabel!
    private var checkinSubtitle: UILabel!
    private var checkinTable: UITableView!
    
    var sortedRegistrants = [Registrant]()
    
    required init(event: Event, sheet: SignupSheet) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.sheetInfo = sheet
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .clear
        view.backgroundColor = EventDraft.backgroundColor
        
        refreshControl.addTarget(self, action: #selector(refreshRegistrants), for: .valueChanged)
        
        banner = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            return v
        }()
        
        checkinTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.lineBreakMode = .byWordWrapping
            label.text = "Online Check-in"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 23, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(label)

            label.leftAnchor.constraint(equalTo: banner.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: banner.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: banner.safeAreaLayoutGuide.topAnchor).isActive = true
            
            return label
        }()
        
        checkinSubtitle = {
            let label = UILabel()
            
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: banner.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: banner.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: checkinTitle.bottomAnchor, constant: 10).isActive = true
            label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        checkinTable = {
            let tv = UITableView()
            tv.dataSource = self
            tv.tableFooterView = UIView()
            tv.separatorStyle = .none
            tv.backgroundColor = .clear
            tv.register(CheckinUserCell.classForCoder(), forCellReuseIdentifier: "user")
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(tv, belowSubview: banner)
            
            tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()

        emptyLabel = {
            let label = UILabel()
            label.isHidden = true
            label.text = "Loading registrants..."
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return label
        }()
        
        refreshRegistrants()
        
        DispatchQueue.main.async {
            self.checkinTable.contentInset.top = self.banner.frame.height - UIApplication.shared.statusBarFrame.height * 2
            self.checkinTable.scrollIndicatorInsets.top = self.checkinTable.contentInset.top
        }
    }
    
    
    private func reloadStats() {
        let word = sheetInfo.currentOccupied == 1 ? "person" : "people"
        if sheetInfo.capacity == 0 {
            checkinSubtitle.text = "\(sheetInfo.currentOccupied) \(word) checked in"
        } else {
            checkinSubtitle.text = "\(sheetInfo.currentOccupied) / \(sheetInfo.capacity) \(word) checked in."
        }
    }
    
    @objc private func refreshRegistrants() {
        let parameters = [
            "sheetId": event.uuid,
            "orgId": event.hostID
        ]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetRegistrants",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.checkinTable.refreshControl = self.refreshControl
                self.refreshControl.endRefreshing()
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) {
                        self.dismiss(animated: true)
                    }
                }
                return
            }
            
            if let json = try? JSON(data: data!).arrayValue {
                var tmp = Set<Registrant>()
                for registrantData in json {
                    tmp.insert(Registrant(json: registrantData))
                }
                self.sheetInfo.currentOccupied = tmp.count
                
                self.sortedRegistrants = tmp.sorted { r1, r2 in
                    r1.checkedInDate.timeIntervalSince(r1.checkedInDate) <= 0
                }
                
                DispatchQueue.main.async {
                    if tmp.count == 0 {
                        self.emptyLabel.text = "No one checked in yet. Be the first!"
                    } else {
                        self.emptyLabel.text = ""
                    }
                    self.reloadStats()
                    self.checkinTable.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CheckinTable: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedRegistrants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! CheckinUserCell
        
        cell.setup(registrant: sortedRegistrants[indexPath.row])
        cell.placeLabel.text = String(indexPath.row + 1)
        
        return cell
    }

}
