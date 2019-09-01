//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinOverview: UIViewController {
    
    private var event: Event!
    
    private var spinner: UIActivityIndicatorView!
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    
    required init(event: Event!) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.tintColor = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return spinner
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    

}
