//
//  TicketCodePreview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketCodePreview: UIViewController {
    
    private var canvas: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ticket QR Code"
        view.backgroundColor = .white
        
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
    }

}
