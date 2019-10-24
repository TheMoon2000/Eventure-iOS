//
//  NewEventCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class NewEventCell: UITableViewCell {

    private var content: NewEventNotification!
    
    private var bgView: UIView!
    private var coverImage: UIImageView!
    private var eventTitle: UILabel!
    private var timeAndLocation: UILabel!
    private var separator: UIView!
    private var eventDescription: TTTAttributedLabel!
    
    required init(content: NewEventNotification) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.content = content
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 9
            view.layer.borderWidth = 1
            view.layer.borderColor = AppColors.line.cgColor
            view.layer.masksToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            view.widthAnchor.constraint(lessThanOrEqualToConstant: 700).isActive = true
            
            return view
        }()
        
        coverImage = {
            let iv = UIImageView(image: content.coverImage ?? #imageLiteral(resourceName: "cover_placeholder"))
            if content.coverImage == nil {
                content.getCover { _ in
                    if content.coverImage != nil { iv.image = content.coverImage }
                }
            }
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: bgView.topAnchor).isActive = true
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 1.5).isActive = true
            
            return iv
        }()
        
        eventTitle = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.text = content.eventTitle
            label.font = .systemFont(ofSize: 19, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 16).isActive = true
            
            return label
        }()
        
        timeAndLocation = {
            let label = UILabel()
            label.text = content.startTime.readableString() + "  |  " + content.location
            label.numberOfLines = 2
            label.textColor = AppColors.prompt
            label.font = .systemFont(ofSize: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 5).isActive = true
            
            return label
        }()
        
        separator = {
            let v = UIView()
            v.backgroundColor = AppColors.line
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            v.heightAnchor.constraint(equalToConstant: 1).isActive = true
            v.topAnchor.constraint(equalTo: timeAndLocation.bottomAnchor, constant: 16).isActive = true
            v.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            return v
        }()
        
        eventDescription = {
            let label = TTTAttributedLabel(frame: .zero)
            
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                label.setText(content.eventSummary.attributedText(style: COMPACT_DARK))
            } else {
                label.setText(content.eventSummary.attributedText(style: COMPACT_STYLE))
            }
            
            label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue +
                NSTextCheckingResult.CheckingType.phoneNumber.rawValue
            
            
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: AppColors.link,
                .underlineStyle: true
            ]
            
            label.linkAttributes = attributes
            label.activeLinkAttributes = attributes
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -16).isActive = true
            
            return label
        }()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            eventDescription.setText(content.eventSummary.attributedText(style: PLAIN_DARK))
        } else {
            eventDescription.setText(content.eventSummary.attributedText(style: PLAIN_STYLE))
        }
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
