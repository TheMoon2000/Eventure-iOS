//
//  TicketsOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/16.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class TicketsOverview: UIViewController {
    
    private var tabs: TicketTabView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Tickets"
        view.backgroundColor = AppColors.background
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addTickets))
        navigationItem.backBarButtonItem = .init(title: "Tickets", style: .plain, target: nil, action: nil)

        tabs = {
            let tabs = TicketTabView()
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
    
    @objc private func addTickets() {
        let addVC = AddTicket(parentVC: tabs.viewControllers[tabs.currentIndex] as! TicketsList)
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }
}
