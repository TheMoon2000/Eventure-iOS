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
    
    required init(ticket: Ticket) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.ticketInfo = ticket
        selectionStyle = .none
        
        ticketType = {
            let label = UILabel()
            label.numberOfLines = 5
            label.textAlignment = .center
            label.text = ticket.admissionType
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textColor = .init(white: 0.1, alpha: 1)
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
            let noun = ticket.quantity == 1 ? "Ticket" : "Tickets"
            label.text = "\(ticket.quantity) " + noun
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: ticketType.bottomAnchor, constant: 9).isActive = true
            
            return label
        }()
        
        qrCode = {
            var data = JSON()
            data.dictionaryObject?["Ticket ID"] = ticket.ticketID
            let iv = UIImageView()
            if let msg = data.rawString([.castNilToNSNull: true]) {
                print(msg)
                iv.image = generateQRCode(from: msg)
            }
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 200).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 200).isActive = true
            iv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: quantity.bottomAnchor, constant: 20).isActive = true
            iv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
            
            return iv
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
