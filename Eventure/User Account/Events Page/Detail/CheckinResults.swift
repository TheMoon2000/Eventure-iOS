//
//  CheckinResults.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftCSVExport
import SwiftLoggly


class CheckinResults: UIViewController {

    private let refreshControl = UIRefreshControl()
    
    private(set) var event: Event!
    private var banner: UIVisualEffectView!
    
    private var emptyLabel: UILabel!
    
    private var checkinTitle: UILabel!
    private var checkinSubtitle: UILabel!
    private var checkinTable: UITableView!
    
    private var bottomBanner: UIVisualEffectView!
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    
    private var orgInfo: Organization?
    
    var sortedRegistrants = [Registrant]() {
        didSet {
            filteredRegistrants = sortedRegistrants.filter { reg in
                return reg.currentCode == nil
            }
        }
    }
    var filteredRegistrants = [Registrant]()
    var displayedRegistrants: [Registrant] {
        return showPending ? sortedRegistrants : filteredRegistrants
    }
    
    var registrantPictures = [Int: UIImage]()
    var sortMethod: Sort = .date
    var sortAscending = true
    var showPending = false
    
    private var NOTHING = "Nothing to display."
    
    private var doc: UIDocumentInteractionController!
    
    required init(event: Event) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let effect: UIVisualEffect
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            effect = UIBlurEffect(style: .dark)
        } else {
            effect = UIBlurEffect(style: .light)
        }
        banner.effect = effect
        bottomBanner.effect = effect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas
        
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(closeSheet))
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(more))
        
        refreshControl.addTarget(self, action: #selector(refreshRegistrants), for: .valueChanged)
        refreshControl.tintColor = AppColors.lightControl
        
        banner = {
            let effect: UIVisualEffect
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                effect = UIBlurEffect(style: .dark)
            } else {
                effect = UIBlurEffect(style: .light)
            }
            let v = UIVisualEffectView(effect: effect)
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
            label.textColor = AppColors.label
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
            label.textColor = AppColors.prompt
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
            tv.delegate = self
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
            label.text = "Loading registrants..."
            label.font = .systemFont(ofSize: 17)
            label.textColor = AppColors.prompt
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        bottomBanner = {
            let effect: UIVisualEffect
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                effect = UIBlurEffect(style: .dark)
            } else {
                effect = UIBlurEffect(style: .light)
            }
            let v = UIVisualEffectView(effect: effect)
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return v
        }()
        
        orgLogo = {
            let iv = UIImageView(image: Organization.current?.logoImage ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.tintColor = AppColors.mainDisabled
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
            label.textColor = AppColors.label
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
    }
    
    
    private func layoutTableInset() {
        
        let topPadding = self.checkinTable.adjustedContentInset.top - self.checkinTable.contentInset.top
        
        self.checkinTable.contentInset.top = self.banner.frame.height - topPadding + 6
        
        self.checkinTable.scrollIndicatorInsets.top =
            self.checkinTable.contentInset.top
        
        checkinTable.contentInset.bottom = bottomBanner.frame.height + 6
        checkinTable.scrollIndicatorInsets.bottom = checkinTable.contentInset.bottom
    }
    
    
    private func reloadStats() {
        
        var textToDisplay = ""
        
        let word = filteredRegistrants.count == 1 ? "person" : "people"
        if event.capacity == 0 {
            if filteredRegistrants.isEmpty {
                textToDisplay = "No one checked in"
            } else {
                textToDisplay = "\(filteredRegistrants.count) \(word) checked in"
            }
        } else {
            textToDisplay = "\(filteredRegistrants.count) / \(event.capacity) \(word) checked in"
        }
        
        if sortedRegistrants.count > filteredRegistrants.count {
            textToDisplay += ", \(sortedRegistrants.count - filteredRegistrants.count) waiting for verification code."
        } else {
            textToDisplay += "."
        }
        
        checkinSubtitle.text = textToDisplay
        
        view.layoutIfNeeded()
        layoutTableInset()
    }
    
    @objc private func more() {
        let alert = UIAlertController(title: "More actions", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        if event.requiresTicket {
            alert.addAction(.init(title: "Scan Ticket", style: .default, handler: { _ in
                let scanner = OrgScanner()
                scanner.event = self.event
                self.navigationController?.pushViewController(scanner, animated: true)
            }))
        }
        alert.addAction(.init(title: "Sort Settings", style: .default, handler: { _ in
            self.openSortMenu()
        }))
        alert.addAction(.init(title: "Export as CSV", style: .default, handler: { _ in
            self.exportDoc()
        }))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.leftBarButtonItem!
        }
        
        present(alert, animated: true)
    }
    
    private func exportDoc() {
        let data : NSMutableArray  = NSMutableArray()
        for r in filteredRegistrants {
            let registrant:NSMutableDictionary = NSMutableDictionary()
            if (r.displayedName == "") {
                if (r.name.isEmpty) {
                    registrant.setObject("incognito", forKey: "name" as NSCopying)
                } else {
                    registrant.setObject(r.name, forKey: "name" as NSCopying)
                }
            } else {
                registrant.setObject(r.displayedName, forKey: "name" as NSCopying)
            }
            registrant.setObject(r.email, forKey: "email" as NSCopying)
            print(r.displayedName)
            print(r.email)
            data.add(registrant)
        }
        let header = ["name","email"]
        let csv = CSV()
        csv.rows = data
        csv.delimiter = DividerType.comma.rawValue
        csv.fields = header as NSArray
        csv.name = "Checked In Spreadsheet"
        let result = CSVExport.export(csv)
        if result.result == .valid {
            guard let filePath =  result.filePath else {
                print("Export Error: \(String(describing: result.message))")
                return
            }
            // Read File and convert as CSV class object
            print(filePath)
            let log = CSVExport.readCSVObject(filePath);
            
            // Use 'SwiftLoggly' pod framework to print the Dictionary
            loggly(LogType.Info, text: log.name)
            
            let _ = UIActivityViewController(activityItems: [filePath], applicationActivities: [])
            
            doc = UIDocumentInteractionController(url: NSURL.fileURL(withPath: filePath))
            doc.presentOptionsMenu(from: navigationItem.leftBarButtonItem!, animated: true)
        } else {
            print("Export Error: \(String(describing: result.message))")
        }
        
        
        
    }
    
    @objc private func closeSheet(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }
    
    @objc private func refreshRegistrants(stealth: Bool = false) {
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
                if !stealth {
                    self.refreshControl.endRefreshing()
                    self.checkinTable.refreshControl = self.refreshControl
                }
            }
            
            guard error == nil else {
                if !stealth {
                    DispatchQueue.main.async {
                        internetUnavailableError(vc: self) {
                            self.dismiss(animated: true)
                        }
                    }
                }
                return
            }
            
            if let json = try? JSON(data: data!).arrayValue {
                DispatchQueue.global(qos: .default).async {
                    var tmp = [Registrant]()
                    var orderedCount = 0
                    for registrantData in json {
                        let registrant = Registrant(json: registrantData)
                        registrant.profilePicture = self.registrantPictures[registrant.userID]
                        tmp.append(registrant)
                        if registrant.currentCode == nil {
                            orderedCount += 1
                            registrant.order = orderedCount
                        }
                    }
                    
                    self.sortedRegistrants = tmp
                    
                    DispatchQueue.main.async {
                        self.resortRegistrants()
                        self.reloadStats()
                    }
                }
            } else {
                if !stealth {
                    DispatchQueue.main.async {
                        serverMaintenanceError(vc: self) {
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // Update the sorted list based on the given algorithm
    func resortRegistrants() {
        DispatchQueue.global(qos: .default).async {
            self.sortedRegistrants.sort { r1, r2 in
                let sortResult: Bool
                if self.sortMethod == .date {
                    if r1.currentCode != nil && r2.currentCode == nil {
                        return true
                    } else if r1.currentCode == nil && r2.currentCode != nil {
                        return false
                    }
                    sortResult = r1.checkedInDate.timeIntervalSince(r2.checkedInDate) < 0
                } else {
                    sortResult = r1.name.lowercased() < r2.name.lowercased()
                }
                return self.sortAscending ? sortResult : !sortResult
            }
            DispatchQueue.main.async {
                self.emptyLabel.text = self.displayedRegistrants.isEmpty ? self.NOTHING : ""
                self.checkinTable.reloadData()
            }
        }
    }
    
    func openSortMenu() {
        let menu = CheckinSortSettings(parentVC: self)
        let nav = UINavigationController(rootViewController: menu)
        nav.navigationBar.tintColor = AppColors.main
        nav.navigationBar.barTintColor = AppColors.navbar
        nav.navigationBar.isTranslucent = false
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.layoutTableInset()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


extension CheckinResults: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedRegistrants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! CheckinUserCell
        
        let current = displayedRegistrants[indexPath.row]
        if current.profilePicture == nil {
            current.getProfilePicture { new in
                cell.profilePicture.image = new.profilePicture
                self.registrantPictures[new.userID] = new.profilePicture
            }
        }
        cell.setup(registrant: current)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let registrant = displayedRegistrants[indexPath.row]
        
        if registrant.showProfile {
            let profilePage = ProfileInfoPage(profile: registrant)
            self.navigationController?.pushViewController(profilePage, animated: true)
        } else {
            let alert = UIAlertController(title: "Profile unavailable", message: nil, preferredStyle: .alert)
            if registrant.userID == -1 {
                alert.message = "This user is registered online and does not have a profile."
            } else {
                alert.message = "This user did not share their profile information for this event."
            }
            alert.addAction(.init(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.view.backgroundColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.view.backgroundColor = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.suppressNotifications = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AppDelegate.suppressNotifications = false
    }

}


extension CheckinResults {
    enum Sort: Int {
        case date = 0, name = 1
    }
}
