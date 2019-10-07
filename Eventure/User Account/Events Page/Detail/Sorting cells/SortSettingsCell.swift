//
//  SortSettingsCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class SortSettingsCell: UITableViewCell {
    
    private(set) var bgView: UIView!
    private(set) var sortTitle: UILabel!
    private(set) var img: UIImageView!
    
    private(set) var style: Style = .middle
    
    var checked = false {
        didSet {
            img.isHidden = !checked
            bgView.backgroundColor = checked ? AppColors.selected : AppColors.subview
            sortTitle.textColor = checked ? AppColors.label : .darkGray
        }
    }

    init(style: Style) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.style = style
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            if style == .top {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if style == .bottom {
                view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                view.layer.maskedCorners = []
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0.5).isActive = true
            
            let h = view.heightAnchor.constraint(equalToConstant: 55)
            h.priority = .defaultLow
            h.isActive = true
            
            let constant: CGFloat = style == .bottom ? -10 : -0.5
            
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: constant)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        sortTitle = {
            let label = UILabel()
            label.alpha = 0.0
            label.font = .systemFont(ofSize: 17)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            return label
        }()
        
        img = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate))
            iv.tintColor = MAIN_TINT
            iv.alpha = 0.0
            iv.isHidden = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 24).isActive = true
            iv.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            
            return iv
        }()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}


extension SortSettingsCell {
    enum Style {
        case top, bottom, middle
    }
}
