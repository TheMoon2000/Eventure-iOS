//
//  GenericTableButton.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/21.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class GenericTableButton: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var buttonTitle: UILabel!

     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
                        
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        buttonTitle = {
            let label = UILabel()
            label.font = .appFontMedium(16)
            label.textColor = AppColors.fatal
            label.textAlignment = .center
            label.numberOfLines = 3
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            bgView.backgroundColor = AppColors.selected
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.bgView.backgroundColor = AppColors.subview
            })
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
