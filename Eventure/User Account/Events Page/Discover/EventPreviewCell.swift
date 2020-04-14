//
//  EventPreviewCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/13.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class EventPreviewCell: UICollectionViewCell {
    
    private var bgView: UIView!
    private(set) var orgLogo: UIImageView!
    private var vStack: UIStackView!
    private(set) var eventTitle: UILabel!
    
    private var startTimeIcon: UIImageView!
    private(set) var startTime: UILabel!
    private var locationIcon: UIImageView!
    private(set) var location: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.layer.cornerRadius = 7
            view.layer.borderWidth = 1
            view.applyMildShadow()
            view.layer.borderColor = AppColors.lineLight.cgColor
            view.backgroundColor = AppColors.card
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            return view
        }()
        
        orgLogo = {
            let iv = UIImageView()
            iv.tintColor = AppColors.mainLight
            iv.layer.cornerRadius = 5
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.layer.borderColor = AppColors.line.cgColor
            iv.layer.borderWidth = 1
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 12).isActive = true
            
            return iv
        }()
        
        eventTitle = {
            let label = UILabel()
            label.font = .appFontSemibold(17)
            label.textColor = AppColors.label
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
            
            let c = label.centerYAnchor.constraint(equalTo: orgLogo.centerYAnchor)
            c.priority = .defaultHigh
            c.isActive = true
            
            return label
        }()
        
        startTime = {
            let label = UILabel()
            label.font = .appFontRegular(14)
            label.textColor = AppColors.prompt
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: orgLogo.bottomAnchor, constant: 7).isActive = true
            label.topAnchor.constraint(greaterThanOrEqualTo: eventTitle.bottomAnchor, constant: 7).isActive = true
            
            let t = label.topAnchor.constraint(equalTo: topAnchor)
            t.priority = .defaultLow
            t.isActive = true
            
            return label
        }()
        
        startTimeIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "datetime").withRenderingMode(.alwaysTemplate))
            icon.tintColor = AppColors.lightControl
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.widthAnchor.constraint(equalToConstant: 15).isActive = true
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            icon.rightAnchor.constraint(equalTo: startTime.leftAnchor, constant: -5).isActive = true
            icon.topAnchor.constraint(equalTo: startTime.topAnchor, constant: 1).isActive = true
            
            return icon
        }()
        
        location = {
            let label = UILabel()
            label.font = .appFontRegular(14)
            label.textColor = AppColors.prompt
            label.numberOfLines = 3
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: startTime.bottomAnchor, constant: 7).isActive = true
            label.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12).isActive = true
            
            return label
        }()
        
        locationIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate))
            icon.tintColor = AppColors.lightControl
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            addSubview(icon)
            
            icon.widthAnchor.constraint(equalTo: startTimeIcon.widthAnchor).isActive = true
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            icon.rightAnchor.constraint(equalTo: location.leftAnchor, constant: -4).isActive = true
            icon.topAnchor.constraint(equalTo: location.topAnchor, constant: 1).isActive = true
            icon.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12).isActive = true
            
            return icon
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                bgView.backgroundColor = AppColors.selected
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.bgView.backgroundColor = AppColors.background
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        DispatchQueue.main.async {
            self.bgView.layer.borderColor = AppColors.lineLight.cgColor
            self.orgLogo.layer.borderColor = AppColors.lineLight.cgColor
        }
    }
}
