//
//  TicketManagerMain.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketManagerMain: UIViewController {
    
    private var tabs: TicketManagerTabs!
    private(set) var event: Event!
    private(set) var admissionType: AdmissionType!
    
    required init(event: Event, admissionType: AdmissionType) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        self.admissionType = admissionType
        self.title = "Manage Tickets"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.shadowImage = nil
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
