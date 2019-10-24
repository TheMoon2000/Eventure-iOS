//
//  MembershipInvitationCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/22.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import BonMot

class MembershipInvitationCell: UITableViewCell {
    
    private var invitation: InviteNotification!
    
    private var bgView: UIView!
    private(set) var titleLabel: UILabel!
    private(set) var separator: UIView!
    private(set) var messageLabel: UILabel!
    private(set) var declineButton: UIButton!
    private(set) var acceptButton: UIButton!
    private var buttonStack: UIStackView!
    
    
    /// Handles whether the user accepted the request.
    var acceptHandler: ((Bool) -> ())?
    
    
    init(invitation: InviteNotification) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.invitation = invitation
        
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
            
            return view
        }()
        
        titleLabel = {
            let label = UILabel()
            label.textColor = AppColors.label
            label.text = "Membership Invitation"
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 18).isActive = true
            
            return label
        }()
        
        separator = {
            let v = UIView()
            v.backgroundColor = AppColors.line
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
            v.heightAnchor.constraint(equalToConstant: 1).isActive = true
            v.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
            v.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            return v
        }()
        
        messageLabel = {
            let label = UILabel()
            
            label.attributedText = NSAttributedString.composed(of: [
                "\(invitation.sender.name) invites you to join as ".styled(with: .basicStyle),
                invitation.role.styled(with: .valueStyle),
                ".".styled(with: .basicStyle)
            ])
            
            label.numberOfLines = 0
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12).isActive = true
            
            return label
        }()
        
        if invitation.status == .pending {
            acceptButton = {
                let button = UIButton()
                button.setTitle("Accept", for: .normal)
                button.setTitleColor(AppColors.plainText, for: .normal)
                button.titleEdgeInsets.left = 8
                button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                button.translatesAutoresizingMaskIntoConstraints = false
                            
                button.addTarget(self, action: #selector(acceptPressed), for: .touchDown)
                button.addTarget(self, action: #selector(acceptLifted), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
                button.addTarget(self, action: #selector(accept), for: .touchUpInside)
                
                return button
            }()
            
            declineButton = {
                let button = UIButton()
                button.setTitle("Decline", for: .normal)
                button.setTitleColor(AppColors.plainText, for: .normal)
                button.titleEdgeInsets.left = 5
                button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                button.translatesAutoresizingMaskIntoConstraints = false
                
                button.addTarget(self, action: #selector(declinePressed), for: .touchDown)
                button.addTarget(self, action: #selector(declineLifted), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
                button.addTarget(self, action: #selector(reject), for: .touchUpInside)
                
                return button
            }()
            
            buttonStack = {
                let stack = UIStackView(arrangedSubviews: [declineButton, acceptButton])
                stack.alignment = .fill
                stack.distribution = .fillEqually
                stack.translatesAutoresizingMaskIntoConstraints = false
                bgView.addSubview(stack)
                
                stack.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
                stack.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
                stack.heightAnchor.constraint(equalToConstant: 38).isActive = true
                stack.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
                
                return stack
            }()
            
            let line = UIView()
            line.backgroundColor = AppColors.line
            line.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(line)
            
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            line.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            line.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 18).isActive = true
            line.topAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
            
            let vLine = UIView()
            vLine.backgroundColor = AppColors.line
            vLine.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(vLine)
            
            vLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
            vLine.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
            vLine.topAnchor.constraint(equalTo: line.topAnchor).isActive = true
            vLine.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
        } else {
            if invitation.status == .accepted {
                messageLabel.attributedText = .composed(of: [
                    "You have accepted the position ".styled(with: .basicStyle),
                    invitation.role.styled(with: .valueStyle),
                    ".".styled(with: .basicStyle)
                ])
            } else {
                messageLabel.attributedText = .composed(of: [
                    "You have declined the position ".styled(with: .basicStyle),
                    invitation.role.styled(with: .valueStyle),
                    ".".styled(with: .basicStyle)
                ])
            }
            messageLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    @objc private func acceptPressed() {
        acceptButton.backgroundColor = AppColors.selected
    }
    
    @objc private func acceptLifted() {
        acceptButton.backgroundColor = AppColors.subview
    }
    
    @objc private func declinePressed() {
        declineButton.backgroundColor = AppColors.selected
    }

    @objc private func declineLifted() {
        declineButton.backgroundColor = AppColors.subview
    }
    
    @objc private func accept() {
        acceptHandler?(true)
    }
    
    @objc private func reject() {
        acceptHandler?(false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
