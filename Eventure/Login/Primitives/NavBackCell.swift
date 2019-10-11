//
//  NavBackCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class NavBackCell: UITableViewCell {
    
    var action: (() -> ())?
    private var button: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .clear

        let h = heightAnchor.constraint(equalToConstant: 40)
        h.priority = .defaultHigh
        h.isActive = true
        button = createButton()
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        button.tintColor = AppColors.main
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    @objc private func buttonPressed() {
        action?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
