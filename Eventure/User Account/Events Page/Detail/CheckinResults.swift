//
//  CheckinResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckinResults: UIViewController {

    private let refreshControl = UIRefreshControl()
    
    private var event: Event!
    private var banner: UIVisualEffectView!
    
    private var emptyLabel: UILabel!
    
    private var checkinTitle: UILabel!
    private var checkinSubtitle: UILabel!
    private var checkinTable: UITableView!
    
    private var bottomBanner: UIVisualEffectView!
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    
    private var orgInfo: Organization?
    
    var sortedRegistrants = [Registrant]()
    var registrantPictures = [Int: UIImage]()
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .clear
        view.backgroundColor = .init(white: 0.92, alpha: 1)
        
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(closeSheet))
        
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
            label.numberOfLines = 5
            label.text = event.title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 22, weight: .medium)
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
            label.text = "Loading..."
            label.numberOfLines = 5
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16.5)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            banner.contentView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: banner.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: banner.rightAnchor, constant: -30).isActive = true
            label.topAnchor.constraint(equalTo: checkinTitle.bottomAnchor, constant: 8).isActive = true
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
        
        bottomBanner = {
            let v = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return v
        }()
        
        orgLogo = {
            let iv = UIImageView(image: Organization.current?.logoImage ?? #imageLiteral(resourceName: "unknown"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bottomBanner.contentView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 30).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(greaterThanOrEqualTo: bottomBanner.leftAnchor, constant: 15).isActive = true
            iv.centerYAnchor.constraint(equalTo: bottomBanner.safeAreaLayoutGuide.centerYAnchor).isActive = true
            iv.topAnchor.constraint(greaterThanOrEqualTo: bottomBanner.topAnchor, constant: 12).isActive = true
            iv.bottomAnchor.constraint(lessThanOrEqualTo: bottomBanner.bottomAnchor, constant: -12).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.lineBreakMode = .byWordWrapping
            label.text = event.hostTitle
            label.font = .systemFont(ofSize: 17.5, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            bottomBanner.contentView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: bottomBanner.rightAnchor, constant: -20).isActive = true
            label.centerXAnchor.constraint(equalTo: bottomBanner.centerXAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: bottomBanner.safeAreaLayoutGuide.centerYAnchor).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: bottomBanner.topAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomBanner.bottomAnchor, constant: -12).isActive = true
            
            return label
        }()
        
        refreshRegistrants()
        
        banner.layoutIfNeeded()
        
        DispatchQueue.main.async {
            
            let topPadding = self.checkinTable.adjustedContentInset.top - self.checkinTable.contentInset.top
            
            
            self.checkinTable.contentInset.top = self.banner.frame.height - topPadding + 5
            self.checkinTable.scrollIndicatorInsets.top = self.checkinTable.contentInset.top
        }
    }
    
    
    private func reloadStats() {
        
        let word = sortedRegistrants.count == 1 ? "person" : "people"
        if event.capacity == 0 {
            checkinSubtitle.text = "\(sortedRegistrants.count) \(word) checked in"
        } else {
            checkinSubtitle.text = "\(sortedRegistrants.count) / \(event.capacity) \(word) checked in."
        }
    }
    
    
    @objc private func closeSheet() {
        dismiss(animated: true, completion: nil)
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
                DispatchQueue.global(qos: .default).async {
                    var tmp = [Registrant]()
                    for registrantData in json {
                        let registrant = Registrant(json: registrantData)
                        registrant.profilePicture = self.registrantPictures[registrant.userID]
                        tmp.append(registrant)
                    }
                    
                    self.sortedRegistrants = tmp.sorted { r1, r2 in
                        r1.checkedInDate < r2.checkedInDate
                    }
                    
                    DispatchQueue.main.async {
                        if tmp.count == 0 {
                            self.emptyLabel.text = "No one checked in yet. Be the first!"
                        } else {
                            self.emptyLabel.text = ""
                        }
                        self.reloadStats()
                        self.checkinTable.reloadSections([0], with: .none)
                    }
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


extension CheckinResults: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sortedRegistrants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! CheckinUserCell
        
        let current = sortedRegistrants[indexPath.row]
        if current.profilePicture == nil {
            current.getProfilePicture { new in
                cell.profilePicture.image = new.profilePicture
                self.registrantPictures[new.userID] = new.profilePicture
            }
        }
        cell.setup(registrant: current)
        cell.placeLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let registrant = sortedRegistrants[indexPath.row]
        print(registrant.name)
    }

}
