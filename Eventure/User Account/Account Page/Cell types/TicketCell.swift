//
//  TicketCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketCell: UITableViewCell {
    
    private var bgView: UIView!
    private var orgLogo: UIImageView!
    private var orgTitle: UILabel!
    private var separatorLine: UIView!
    private var eventTitle: UILabel!
    private var dateLabel: UILabel!
    private var dateValue: UILabel!
    private var paymentTypeLabel: UILabel!
    private var paymentTypeValue: UILabel!
    private var countLabel: UILabel!
    private var countValue: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
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
        
        orgLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.tintColor = MAIN_DISABLED
            iv.layer.cornerRadius = 3
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.font = .systemFont(ofSize: 15)
            label.textColor = UIColor(white: 0.4, alpha: 1)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            label.centerYAnchor.constraint(equalTo: orgLogo.centerYAnchor).isActive = true
            
            return label
        }()
        
        separatorLine = {
            let line = UIView()
            line.backgroundColor = AppColors.line
            line.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(line)
            
            line.topAnchor.constraint(equalTo: orgTitle.bottomAnchor, constant: 15).isActive = true
            line.leftAnchor.constraint(equalTo: orgLogo.leftAnchor).isActive = true
            line.rightAnchor.constraint(equalTo: orgTitle.rightAnchor).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        eventTitle = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 20, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: orgTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 18).isActive = true
            
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Date of event: "
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 18).isActive = true
            
            return label
        }()
        
        dateValue = {
            let label = UILabel()
            label.numberOfLines = 2
            label.textAlignment = .right
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: orgTitle.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: dateLabel.topAnchor).isActive = true
            
            return label
        }()
        
        paymentTypeLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Payment type: "
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        paymentTypeValue = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 2
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: paymentTypeLabel.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: dateValue.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: paymentTypeLabel.topAnchor).isActive = true
            
            return label
        }()
        
        countLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Party size: "
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: paymentTypeValue.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        countValue = {
            let label = UILabel()
            label.textAlignment = .right
            label.numberOfLines = 2
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: countLabel.rightAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: dateValue.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: countLabel.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
    }
    
    func setup(ticket: Ticket) {
        if let logo = ticket.orgLogo {
            self.orgLogo.image = logo
        } else {
            // load the logo image
        }
        orgTitle.text = ticket.hostName
        eventTitle.text = ticket.eventName
        if let date = ticket.eventDate {
            dateValue.text = date.readableString()
        } else {
            dateValue.text = "Unknown"
        }
        paymentTypeValue.text = ticket.paymentType.rawValue
        countValue.text = ticket.quantity == 1 ? "1 Person" : "\(ticket.quantity) People"
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
