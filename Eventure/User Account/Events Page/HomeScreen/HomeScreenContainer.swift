//
//  HomeScreenContainer.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/12.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class HomeScreenContainer: UIViewController, FlowProgressReporting {
    
    let flowProgress: CGFloat = 0.0
    
    private var homescreen: HomeScreen!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Events"
        
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(options))
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "search"), style: .plain, target: self, action: #selector(search))
                
        // Do any additional setup after loading the view.
        homescreen = {
            let hs = HomeScreen(container: self)
            hs.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hs.view)
            
            hs.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            hs.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            hs.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            hs.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            addChild(hs)
            hs.didMove(toParent: self)
            
            return hs
        }()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.barTintColor = AppColors.darkerNavBar
    }
    
    @objc private func options() {
    }
    
    @objc private func search() {
        let vc = EventSearchView()
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    

}
