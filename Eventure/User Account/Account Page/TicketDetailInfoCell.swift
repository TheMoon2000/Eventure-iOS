//
//  TicketDetailInfoCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/18.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketDetailInfoCell: UITableViewCell {
    
    private var providerLabel: UILabel!
    private var provider: UILabel!
    private var paymentDateLabel: UILabel!
    private var paymentDate: UILabel!
    private var paymentTypeLabel: UILabel!
    private var paymentType: UILabel!
    private var ticketPriceLabel: UILabel!
    private var ticketPrice: UILabel!
    private var amountPaidLabel: UILabel!
    private var amountPaid: UILabel!
    private var notesLabel: UILabel!
    private var notes: UILabel!
    
    required init(ticket: Ticket) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        
        providerLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Ticket provider:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
            
            return label
        }()
        
        provider = {
            let label = UILabel()
            label.numberOfLines = 10
            label.attributedText = ticket.hostName.attributedText(style: COMPACT_STYLE)
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: providerLabel.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: providerLabel.topAnchor).isActive = true
            
            return label
        }()
        
        paymentDateLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Date of purchase:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: provider.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
            
            return label
        }()
        
        paymentDate = {
            let label = UILabel()
            label.numberOfLines = 2
            label.text = ticket.transactionDate?.readableString() ?? "Unrecorded"
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: paymentDateLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: paymentDateLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        paymentTypeLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Payment type:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: paymentDate.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        paymentType = {
            let label = UILabel()
            label.numberOfLines = 2
            label.text = ticket.paymentType.rawValue
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: paymentTypeLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: paymentTypeLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        ticketPriceLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Ticket price:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: paymentType.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        ticketPrice = {
            let label = UILabel()
            label.text = String(format: "$%.02f", ticket.ticketPrice)
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: ticketPriceLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: ticketPriceLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        amountPaidLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Amount paid:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: ticketPrice.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        amountPaid = {
            let label = UILabel()
            label.numberOfLines = 2
            label.text = String(format: "$%.02f", ticket.paymentAmount)
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: amountPaidLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: amountPaidLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        if ticket.notes.isEmpty {
            amountPaid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            return
        }
        
        notesLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Notes:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: amountPaid.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            return label
        }()
        
        notes = {
            let label = UILabel()
            label.numberOfLines = 10
            label.attributedText = ticket.notes.attributedText(style: COMPACT_STYLE)
            if label.text!.isEmpty {
                label.attributedText = "*The event host did not leave a note.*".attributedText(style: COMPACT_STYLE)
            }
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: notesLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: notesLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        notes.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
