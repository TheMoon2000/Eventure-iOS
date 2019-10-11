//
//  TicketManagerMain.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketManagerMain: UIViewController {
    
    private(set) var center: TicketCenter!
    private var tabs: TicketManagerTabs!
    private(set) var event: Event!
    private(set) var admissionType: AdmissionType!
    
    required init(event: Event, center: TicketCenter, type: AdmissionType) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.center = center
        self.admissionType = type
        self.title = admissionType.typeName
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.canvas
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(createTicket))

        tabs = {
            let tabs = TicketManagerTabs(parentVC: self)
            tabs.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tabs.view)
            
            tabs.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabs.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tabs.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            tabs.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            addChild(tabs)
            tabs.didMove(toParent: self)
            
            return tabs
        }()
    }
    
    func reloadPurchases() {
        (tabs.viewControllers.first as? TicketPurchases)?.loadPurchases()
        center.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
    }
    
    @objc private func createTicket() {
        
        guard let issued = tabs.viewControllers.last as? IssuedTickets else { return }
        
        issued.loadViewIfNeeded()
        
        if (admissionType.quota ?? 0) > 0 && admissionType.quantitySold >= admissionType.quota! {
            let alert = UIAlertController(title: "You cannot distribute more tickets", message: "The number of existing tickets has already reached the quota you set for '\(admissionType.typeName)'. If you want to sell more tickets, you should first go to the event editor to increase the quota.", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        
        let vc = CreateNewTicket(parentVC: issued)
        vc.doneHandler = { new in
            issued.loadTickets()
            issued.tableView.contentOffset.y = 0
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
