//
//  TicketDetailInfoCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/18.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketDetailInfoCell: UITableViewCell {
    
    private var ticketStatusLabel: UILabel!
    private var ticketStatus: UILabel!
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
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
