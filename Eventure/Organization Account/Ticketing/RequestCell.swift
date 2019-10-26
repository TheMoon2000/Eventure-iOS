//
//  RequestCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    
    private var bgView: UIView!
    private var message: UILabel!
    private var separator: UIView!
    
    private var dateLabel: UILabel!
    private var dateValue: UILabel!
    private var emailLabel: UILabel!
    private var emailValue: UIButton!
    
    private var noteLabel: UILabel!
    private var noteValue: UILabel!
    
    private var acceptButton: UIButton!
    private var declineButton: UIButton!
    private var buttonStack: UIStackView!
    
    var acceptHandler: (() -> ())?
    var declineHandler: (() -> ())?
    
    private var GREEN = UIColor(red: 24/255, green: 180/255, blue: 11/255, alpha: 1)
    
    private var requestInfo: TicketRequest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 8
            view.layer.borderWidth = 1
            view.layer.borderColor = AppColors.line.cgColor
            view.layer.masksToBounds = true
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        message = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        separator = {
            let view = UIView()
            view.backgroundColor = AppColors.line
            view.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(view)
            
            view.leftAnchor.constraint(equalTo: message.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: message.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 16).isActive = true
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return view
        }()
        
        dateLabel = {
            let label = UILabel()
            label.text = "Requested on:"
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        dateValue = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        emailLabel = {
            let label = UILabel()
            label.text = "User email:"
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: dateValue.bottomAnchor, constant: 12).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        emailValue = {
            let button = UIButton(type: .system)
            button.tintColor = AppColors.link
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 3
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(button)
            
            button.titleLabel?.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 12).isActive = true
            button.titleLabel?.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            button.titleLabel?.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
            button.titleLabel?.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            button.addTarget(self, action: #selector(emailUser), for: .touchUpInside)
            
            return button
        }()
        
        noteLabel = {
            let label = UILabel()
            label.text = "Note:"
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: emailValue.bottomAnchor, constant: 16).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        noteValue = {
            let label = UILabel()
            label.numberOfLines = 20
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: noteLabel.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: noteLabel.topAnchor).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        acceptButton = {
            let button = UIButton(type: .system)
            button.setTitle("APPROVE", for: .normal)
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleEdgeInsets.left = 8
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.tintColor = GREEN
            button.backgroundColor = AppColors.passed.withAlphaComponent(0.1)
            button.translatesAutoresizingMaskIntoConstraints = false
                        
            button.addTarget(self, action: #selector(accept), for: .touchUpInside)
            
            return button
        }()
        
        declineButton = {
            let button = UIButton(type: .system)
            button.setTitle("DECLINE", for: .normal)
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleEdgeInsets.left = 5
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.tintColor = AppColors.fatal
            button.backgroundColor = AppColors.fatal.withAlphaComponent(0.1)
            button.translatesAutoresizingMaskIntoConstraints = false
                        
            button.addTarget(self, action: #selector(reject), for: .touchUpInside)
            
            return button
        }()
                
        buttonStack = {
            let stack = UIStackView(arrangedSubviews: [acceptButton, declineButton])
            stack.alignment = .fill
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(stack)
            
            stack.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            stack.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stack.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
            
            return stack
        }()
        
        let line = UIView()
        line.backgroundColor = AppColors.line
        line.translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: buttonStack.topAnchor).isActive = true
    }
    
    @objc private func accept() {
        DispatchQueue.main.async {
            self.acceptHandler?()
        }
        
    }
    
    @objc private func reject() {
        DispatchQueue.main.async {
            self.declineHandler?()
        }
    }
    
    @objc private func emailUser() {
        if let email = requestInfo?.email {
            UIApplication.shared.open(URL(string: "mailto:" + email)!, options: [:], completionHandler: nil)
        }
    }
    
    func animateAccept(_ completion: ((Bool) -> ())?) {
        UIView.transition(with: self, duration: 0.3, options: .curveEaseInOut, animations: {
            self.declineButton.isHidden = true
            self.acceptButton.setTitle("APPROVED", for: .normal)
            self.acceptButton.backgroundColor = self.GREEN.withAlphaComponent(0.12)
            self.acceptButton.setImage(UIImage(named: "check"), for: .normal)
        }, completion: completion)
    }
    
    func animateReject(_ completion : ((Bool) -> ())?) {
        UIView.transition(with: self, duration: 0.3, options: .curveEaseInOut, animations: {
            self.acceptButton.isHidden = true
            self.declineButton.setTitle("DECLINED", for: .normal)
            self.declineButton.backgroundColor = AppColors.fatal.withAlphaComponent(0.12)
            self.declineButton.setImage(UIImage(named: "cross"), for: .normal)
        }, completion: completion)
    }
    
    func setup(requestInfo: TicketRequest) {
        self.declineButton.isHidden = false
        self.requestInfo = requestInfo
        let username = requestInfo.username.isEmpty ? "<user #\(requestInfo.userID)>" : requestInfo.username
        let noun = requestInfo.quantity == 1 ? "ticket" : "tickets"
        message.attributedText = "**\(username)** has requested \(requestInfo.quantity) \(noun).".attributedText(style: TITLE_STYLE)
        message.textColor = AppColors.value
        emailValue.setTitle(requestInfo.email, for: .normal)
        
        if requestInfo.notes.isEmpty {
            noteLabel.isHidden = true
            noteValue.isHidden = true
            
            buttonStack.topAnchor.constraint(equalTo: emailValue.bottomAnchor, constant: 16).isActive = true
        } else {
            noteValue.text = requestInfo.notes
            buttonStack.topAnchor.constraint(equalTo: noteValue.bottomAnchor, constant: 16).isActive = true
        }
        
        if requestInfo.requestDate != nil {
            dateValue.text = requestInfo.requestDate!.readableString()
        } else {
            dateValue.text = "Unknown"
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
