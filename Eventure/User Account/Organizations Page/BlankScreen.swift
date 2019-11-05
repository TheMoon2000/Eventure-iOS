//
//  BlankScreen.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class BlankScreen: UIViewController {
    
    private var blockBG: UIView!
    private var blockText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        blockBG = {
            let b = UIView()
            b.backgroundColor = AppColors.background
            b.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(b)
            
            b.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            b.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            b.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            b.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return b
        }()
        
        blockText = {
            let label = UILabel()
            label.text = "Nothing to show."
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            blockBG.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: blockBG.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: blockBG.centerYAnchor).isActive = true
            
            return label
        }()
    }


}
