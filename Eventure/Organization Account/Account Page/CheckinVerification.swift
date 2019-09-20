//
//  CheckinVerification.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinVerification: UIViewController {
    
    private var canvas: UIScrollView!
    private var userProfile: UIImageView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        canvas = {
            let canvas = UIScrollView()
            canvas.alwaysBounceVertical = true
            canvas.contentInsetAdjustmentBehavior = .always
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return canvas
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView()
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Checking in..."
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 8).isActive = true
            
            return label
        }()
        
        
    }
    

    

}
