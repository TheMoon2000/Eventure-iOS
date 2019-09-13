//
//  CheckinPageController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class CheckinPageController: UIPageViewController {
    
    private var event: Event!

    private var sheetInfo: SignupSheet?
    
    private var spinner: UIActivityIndicatorView!
    
    required init(event: Event!) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.event = event
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Loading..."
        view.tintColor = MAIN_TINT
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .done, target: self, action: #selector(closeCheckin))
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            return spinner
        }()

        self.loadSheetInfo()
    }
    
    private func loadSheetInfo() {
        let parameters = [
            "sheetId": event.uuid,
            "userId": String(User.current!.uuid),
            "orgId": event.hostID
        ]
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetCheckinSheet",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
                return
            }
            
            if let json = try? JSON(data: data!) {
                self.sheetInfo = SignupSheet(json: json)
                DispatchQueue.main.async {
                    self.checkIfReady()
                }
            } else {
                print(String(data: data!, encoding: .utf8)!)
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) { self.dismiss(animated: true, completion: nil) }
                }
            }
            
        }
        
        task.resume()
        
    }
    
    /// Both the check-in list information and the registrant data need to be loaded before we present either one of the child view controllers.
    func checkIfReady() {
        
        if sheetInfo == nil { return }
        
        let vc: UIViewController
        
        if !sheetInfo!.currentUserCheckedIn {
            if (event.startTime! > Date()) {
                navigationItem.title = "Event Registration"
                vc = CheckinOverview(parentVC: self, event: event, sheetInfo: sheetInfo!)
            } else {
                navigationItem.title = "Checkin Overview"
                vc = CheckinOverview(parentVC: self, event: event, sheetInfo: sheetInfo!)
            }
        } else {
            navigationItem.title = ""
            vc = CheckinTable(event: event)
        }
        spinner.stopAnimating()
        self.setViewControllers([vc], direction: .forward, animated: true)
    }
    
    @objc private func closeCheckin() {
        self.dismiss(animated: true)
    }
    
    func flipPage() {
        let vc = CheckinTable(event: event)
        navigationItem.title = ""
        self.setViewControllers([vc], direction: .forward, animated: true)
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
