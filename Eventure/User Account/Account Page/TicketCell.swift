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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
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
        
        orgLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.tintColor = MAIN_DISABLED
            iv.layer.cornerRadius = 3
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8).isActive = true
            
            return iv
        }()
        
        orgTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.font = .systemFont(ofSize: 15)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 8).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -12).isActive = true
            label.centerYAnchor.constraint(equalTo: orgLogo.centerYAnchor).isActive = true
            
            return label
        }()
        
        separatorLine = {
            let line = UIView()
            line.backgroundColor = LINE_TINT
            line.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(line)
            
            line.topAnchor.constraint(equalTo: orgTitle.bottomAnchor, constant: 10).isActive = true
            line.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 8).isActive = true
            line.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -8).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        eventTitle = {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 19, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            label.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
    }
    
    func setup(ticket: Ticket) {
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        bgView.backgroundColor = selected ? .init(white: 0.96, alpha: 1) : .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
