//
//  PurchaseDetailsCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class PurchaseDetailsCell: UITableViewCell {

    private var recipientLabel: UILabel!
    private var recipient: UILabel!
    private var emailLabel: UILabel!
    private var emailValue: UILabel!
    private var paymentDateLabel: UILabel!
    private var paymentDate: UILabel!
    private var paymentTypeLabel: UILabel!
    private var paymentType: UILabel!
    private var quantityLabel: UILabel!
    private var quantityValue: UILabel!
    private var amountPaidLabel: UILabel!
    private var amountPaid: UILabel!
    private var notesLabel: UILabel!
    private var notes: UILabel!
    
    required init(ticket: Ticket) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        
        recipientLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Ticket recipient:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
            
            return label
        }()
        
        recipient = {
            let label = UILabel()
            label.numberOfLines = 10
            label.text = ticket.username
            label.textAlignment = .right
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: recipientLabel.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: recipientLabel.topAnchor).isActive = true
            
            return label
        }()
        
        emailLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Recipient email:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: recipient.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
            
            return label
        }()
        
        emailValue = {
            let label = UILabel()
            label.numberOfLines = 3
            label.text = ticket.userEmail ?? "Unknown"
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: emailLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        paymentDateLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Transaction date:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: emailValue.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            
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
        
        quantityLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Quantity:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: paymentDate.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        quantityValue = {
            let label = UILabel()
            let noun = ticket.quantity == 1 ? "Ticket" : "Tickets"
            label.text = "\(ticket.quantity) " + noun
            label.textAlignment = .right
            label.font = .systemFont(ofSize: 16)
            label.textColor = VALUE_COLOR
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: quantityLabel.rightAnchor, constant: 12).isActive = true
            label.topAnchor.constraint(equalTo: quantityLabel.topAnchor).isActive = true
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
            label.topAnchor.constraint(equalTo: quantityValue.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
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
        
        amountPaidLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.text = "Amount paid:"
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: paymentType.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        amountPaid = {
            let label = UILabel()
            label.numberOfLines = 2
            label.text = ticket.paymentDescription
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
        
        if !ticket.notes.isEmpty {
            notesLabel = {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16)
                label.text = "Note:"
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
                label.numberOfLines = 2
                label.text = ticket.notes
                label.textAlignment = .right
                label.font = .systemFont(ofSize: 16)
                label.textColor = VALUE_COLOR
                label.translatesAutoresizingMaskIntoConstraints = false
                addSubview(label)
                
                label.leftAnchor.constraint(equalTo: notesLabel.rightAnchor, constant: 12).isActive = true
                label.topAnchor.constraint(equalTo: notesLabel.topAnchor).isActive = true
                label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
                
                return label
            }()
        
            notes.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        } else {
            amountPaid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
