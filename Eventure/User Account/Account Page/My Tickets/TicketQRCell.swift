//
//  TicketQRCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/18.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class TicketQRCell: UITableViewCell {

    private var ticketType: UILabel!
    private var quantity: UILabel!
    private var ticketInfo: Ticket!
    private var qrCode: UIImageView!
    private var activationLabel: UILabel!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                qrCode.image = ticketInfo.QRCodeDark
            } else {
                qrCode.image = ticketInfo.QRCode
            }
        }
    }
    
    required init(ticket: Ticket) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.ticketInfo = ticket
        selectionStyle = .none
        backgroundColor = AppColors.background
        
        ticketType = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textAlignment = .center
            label.text = ticket.typeName
            label.font = .appFontSemibold(24)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            label.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            return label
        }()
        
        quantity = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .gray
            label.font = .appFontRegular(17)
            let noun = ticket.quantity == 1 ? "Ticket" : "Tickets"
            
            var remaining = ""
            if ticket.quantity > 1 && ticket.remaining < ticket.quantity {
                remaining = " (\(ticket.quantity - ticket.remaining) used)"
            }
            
            label.text = "\(ticket.quantity) " + noun + remaining
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: ticketType.bottomAnchor, constant: 9).isActive = true
            
            return label
        }()
        
        qrCode = {
            let iv = UIImageView(image: ticket.QRCode)
            
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    iv.image = ticket.QRCodeDark
                }
            }
            
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 200).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 200).isActive = true
            iv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: quantity.bottomAnchor, constant: 20).isActive = true
            iv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
            
            return iv
        }()
        
        activationLabel = {
            let label = UILabel()
            label.numberOfLines = 5
            if let activationDate = ticket.activationDate, ticket.remaining == 0 {
                label.attributedText = "Activated \(activationDate.inlineString())".attributedText()
                qrCode.alpha = 0.09
            }
            label.font = .appFontMedium(18)
            label.textAlignment = .center
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: qrCode.leftAnchor, constant: -15).isActive = true
            label.rightAnchor.constraint(equalTo: qrCode.rightAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: qrCode.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
