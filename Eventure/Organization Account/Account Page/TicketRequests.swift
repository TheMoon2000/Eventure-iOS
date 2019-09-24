//
//  TicketRequests.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class TicketRequests: UITableViewController, IndicatorInfoProvider {

    private var parentVC: TicketManagerMain!
    private var admissionType: AdmissionType {
        return parentVC.admissionType
    }
    private var currentRequests = [TicketRequest]()
    
    private var rc = UIRefreshControl()
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!

    required init(parentVC: TicketManagerMain) {
        super.init(nibName: nil, bundle: nil)
        
        self.parentVC = parentVC
        
        refreshControl = UIRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        parentVC.navigationItem.backBarButtonItem = .init(title: "Requests", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.backgroundColor = EventDraft.backgroundColor

        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        fetchRequests()
        
        NotificationCenter.default.addObserver(self, selector: #selector(backgroundUpdate), name: NEW_TICKET_REQUEST, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func backgroundUpdate() {
        fetchRequests(pulled: false, stealth: true)
    }
    
    @objc private func refresh() {
        fetchRequests(pulled: true)
    }
    
    private func fetchRequests(pulled: Bool = false, stealth: Bool = false) {
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        if !stealth {
            emptyLabel.text = ""
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ListTicketRequests",
                           parameters: ["admissionId": admissionType.id])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                if !pulled {
                    self.loadingBG.isHidden = true
                    self.tableView.refreshControl = self.rc
                } else {
                    self.rc.endRefreshing()
                }
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = CONNECTION_ERROR
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let json = try? JSON(data: data!), let requests = json.array {
                var tmp = [TicketRequest]()
                for r in requests {
                    tmp.append(TicketRequest(json: r))
                }
                self.currentRequests = tmp
                
                DispatchQueue.main.async {
                    self.emptyLabel.text = tmp.isEmpty ? "No requests" : ""
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
                    serverMaintenanceError(vc: self)
                }
            }
        }
        
        task.resume()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = RequestCell()

        let currentRequest = currentRequests[indexPath.row]
        cell.setup(requestInfo: currentRequest)
        cell.acceptHandler = {
            let alert = UIAlertController(title: "Approve ticket request?", message: "It is your responsibility to confirm that this user has already made any necessary payments to be eligible for their ticket(s). Once a ticket is given out it cannot be withdrawn.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Approve", style: .default, handler: { _ in
                self.approveRequest(self.tableView.indexPath(for: cell)!, cell: cell)
            }))
            self.present(alert, animated: true)
        }
        cell.declineHandler = {
            let alert = UIAlertController(title: "Decline ticket request?", message: "You are about to remove this ticket request. You cannot undo this action.", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Decline", style: .default, handler: { _ in
                self.declineRequest(self.tableView.indexPath(for: cell)!, cell: cell)
            }))
            self.present(alert, animated: true)
        }

        return cell
    }
    
    func approveRequest(_ indexPath: IndexPath, cell: RequestCell) {
        let currentRequest = currentRequests[indexPath.row]
        loadingBG.isHidden = false
        tableView.refreshControl = nil
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/ApproveTicketRequest",
                           parameters: [
                            "admissionId": currentRequest.admissionID,
                            "userId": String(currentRequest.userID),
                            "ticketId": UUID().uuidString.lowercased(),
                            "requestDate": DATE_FORMATTER.string(from: currentRequest.requestDate ?? Date())
        ])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
                self.tableView.refreshControl = self.rc
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
                DispatchQueue.main.async {
                    cell.animateAccept { _ in
                        self.parentVC.reloadPurchases()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.currentRequests.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            if self.currentRequests.isEmpty { self.emptyLabel.text = "No requests" }
                        }
                    }
                }
            default:
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            
        }
        
        task.resume()
    }
    
    func declineRequest(_ indexPath: IndexPath, cell: RequestCell) {
        let currentRequest = currentRequests[indexPath.row]
        loadingBG.isHidden = false
        tableView.refreshControl = nil
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/DeclineTicketRequest",
                           parameters: [
                            "admissionId": currentRequest.admissionID,
                            "userId": String(currentRequest.userID),
                            "requestDate": DATE_FORMATTER.string(from: currentRequest.requestDate ?? Date())
        ])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.loadingBG.isHidden = true
                self.tableView.refreshControl = self.rc
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
                DispatchQueue.main.async {
                    cell.animateReject { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.currentRequests.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            if self.currentRequests.isEmpty { self.emptyLabel.text = "No requests" }
                        }
                    }
                }
            default:
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
            
        }
        
        task.resume()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Requests")
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
