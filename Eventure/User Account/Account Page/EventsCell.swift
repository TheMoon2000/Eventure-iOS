//
//  EventsCell.swift
//  Eventure
//
//  Created by jeffhe on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//


import UIKit

class EventsCell: UITableViewCell {
    
    private(set) var icon: UIImageView!
    private(set) var titleLabel: UILabel!
    private(set) var dateLabel: UILabel!
    private(set) var imageWidthConstraint: NSLayoutConstraint!
    private(set) var heightConstraint: NSLayoutConstraint!
    private(set) var spacingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //add arrow to each cell
        accessoryType = .disclosureIndicator
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 90)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = MAIN_TINT
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            imageWidthConstraint = iv.widthAnchor.constraint(equalToConstant: 60)
            imageWidthConstraint.isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        
        titleLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.textColor = UIColor.gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15).isActive = true
            
            return label
        } ()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
