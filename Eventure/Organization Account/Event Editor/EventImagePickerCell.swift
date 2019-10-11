//
//  EventImagePickerCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventImagePickerCell: UITableViewCell {
    
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var indicator: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Cover Image:"
            label.textColor = AppColors.label
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        indicator = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate))
            iv.tintColor = .lightGray
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 22).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 22).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            
            return iv
        }()
        
    }
    
    func expand() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }
    
    func collapse() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: 0)
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
