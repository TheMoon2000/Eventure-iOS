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
        
        view.backgroundColor = EventDraft.backgroundColor
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(createTicket))
        navigationItem.backBarButtonItem = .init(title: "Purchases", style: .plain, target: nil, action: nil)

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
        tabs.viewControllers.last?.loadViewIfNeeded()
        let vc = CreateNewTicket(parentVC: tabs.viewControllers.last as! IssuedTickets)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
