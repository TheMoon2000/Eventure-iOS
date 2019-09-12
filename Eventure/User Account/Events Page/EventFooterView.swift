//
//  EventFooterView.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventFooterView: UICollectionReusableView {
    
    private(set) var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        textLabel = {
            let label = UILabel()
            label.alpha = 0.0
            label.text = "Load more..."
            label.textColor = .gray
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
