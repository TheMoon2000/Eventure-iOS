//
//  EventUpdateCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventUpdateCell: UITableViewCell {
    
    private var content: EventUpdateNotification!
    private var parentVC: MessageScreen!
    
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var separator: UIView!
    private var messageLabel: UILabel!
    private var eventDetailsButton: UIButton!
    private var disclosure: UIImageView!

    required init(content: EventUpdateNotification, parent: MessageScreen) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.content = content
        self.parentVC = parent
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 9
            view.layer.borderWidth = 1
            view.layer.borderColor = AppColors.line.cgColor
            view.layer.masksToBounds = true
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.text = "Event Update"
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 18).isActive = true
            
            return label
        }()
        
        separator = {
            let v = UIView()
            v.backgroundColor = AppColors.line
            v.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
            v.heightAnchor.constraint(equalToConstant: 1).isActive = true
            v.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
            v.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            return v
        }()
        
        
        messageLabel = {
            let label = UILabel()
            label.attributedText = content.shortString
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12).isActive = true
            
            return label
        }()
        
        let line: UIView = {
            let line = UIView()
            line.alpha = 0.5
            line.backgroundColor = AppColors.line
            line.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(line)
            
            line.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 18).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            line.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
            line.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            
            return line
        }()
        
        eventDetailsButton = {
            let button = UIButton()
            button.setTitle("Event Details", for: .normal)
            button.setTitleColor(AppColors.value, for: .normal)
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets.left = 15
            button.titleLabel?.font = .systemFont(ofSize: 15)
            button.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(button)
            
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: line.bottomAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
                        
            button.addTarget(self, action: #selector(detailButtonPressed), for: .touchDown)
            button.addTarget(self, action: #selector(detailButtonLifted), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
            button.addTarget(self, action: #selector(goToDetails), for: .touchUpInside)
            
            return button
        }()
        
        disclosure = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate))
            iv.tintColor = AppColors.lightControl
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 25).isActive = true
            iv.centerYAnchor.constraint(equalTo: eventDetailsButton.centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            
            return iv
        }()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    @objc private func detailButtonPressed() {
        eventDetailsButton.backgroundColor = AppColors.selected
    }
    
    @objc private func detailButtonLifted() {
        eventDetailsButton.backgroundColor = AppColors.subview
    }
    
    @objc private func goToDetails() {
        parentVC.openEvent(eventID: content.eventID)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
