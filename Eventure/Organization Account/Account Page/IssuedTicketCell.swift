//
//  IssuedTicketCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class IssuedTicketCell: UITableViewCell {
    
    private var bgView: UIView!
    private var ticketTitle: UILabel!
    private var separator: UIView!
    private var issuedDateLabel: UILabel!
    private var issuedDate: UILabel!
    private var statusLabel: UILabel!
    private var status: UILabel!
    private var extraLabel: UILabel!
    private var extra: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 8
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
        
        ticketTitle = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 19, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 16).isActive = true
            
            return label
        }()
        
        separator = {
            let line = UIView()
            line.backgroundColor = LINE_TINT
            line.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(line)
            
            line.topAnchor.constraint(equalTo: ticketTitle.bottomAnchor, constant: 15).isActive = true
            line.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            line.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        issuedDateLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Issued on:"
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 15).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        issuedDate = {
            let label = UILabel()
            label.numberOfLines = 3
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: issuedDateLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: issuedDateLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        
        statusLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Status:"
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: issuedDate.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        status = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: statusLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: statusLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        extraLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Redeemed on:"
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: separator.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: status.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        extra = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: extraLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: extraLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: separator.rightAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
    }
    
    func setup(ticket: Ticket) {
        let noun = ticket.quantity == 1 ? "ticket" : "tickets"
        ticketTitle.text = ticket.typeName + " (\(ticket.quantity) \(noun))"
        issuedDate.text = ticket.creationDate?.readableString() ?? "Unknown"
        if ticket.redeemCode != nil {
            status.text = "Not yet redeemed"
            extraLabel.text = "Redeem code:"
            extra.text = ticket.redeemCode ?? "Error"
        } else {
            if ticket.username != nil {
                status.text = "Redeemed by \(ticket.username!)"
            } else {
                status.text = "Redeemed"
            }
            status.textColor = VALUE_COLOR
            
            extraLabel.text = "Redeemed on:"
            extra.text = ticket.transactionDate?.readableString() ?? "Unknown"
        }
        
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        bgView.backgroundColor = highlighted ? .init(white: 0.96, alpha: 1) : .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
