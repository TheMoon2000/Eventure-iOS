//
//  TicketNotificationCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/28.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TicketNotificationCell: UITableViewCell, TTTAttributedLabelDelegate {

    private var parentVC: MessageScreen!
    
    private var bgView: UIView!
    private var titleLabel: TTTAttributedLabel!
    
    required init(content: TicketNotification, parent: MessageScreen) {
        super.init(style: .default, reuseIdentifier: nil)
        
        parentVC = parent
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let v = UIView()
            v.backgroundColor = AppColors.messageHeader
            v.layer.cornerRadius = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            v.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            v.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
            v.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            return v
        }()
        
        
        titleLabel = {
            let label = TTTAttributedLabel(frame: .zero)
            
            label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue +
                NSTextCheckingResult.CheckingType.phoneNumber.rawValue
            
            
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: AppColors.link,
                .underlineStyle: true
            ]
            
            let activeAttributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: AppColors.linkPressed,
                .underlineStyle: true
            ]
            
            label.linkAttributes = attributes
            label.activeLinkAttributes = activeAttributes
            label.delegate = self
            
            label.setText(content.displayString)
            label.numberOfLines = 6
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -5).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let ticketCenter = TicketsOverview()
        parentVC.navigationController?.pushViewController(ticketCenter, animated: true)
    }
    
}
