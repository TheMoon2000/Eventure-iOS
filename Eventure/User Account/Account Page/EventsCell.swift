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
        backgroundColor = AppColors.background
        
        icon = {
            let iv = UIImageView()
            iv.tintColor = AppColors.main
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
            label.textColor = AppColors.label
            label.numberOfLines = 10
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.lineBreakMode = .byWordWrapping
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -32).isActive = true
            
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            spacingConstraint = label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15)
            spacingConstraint.isActive = true
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            label.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
            
            return label
        } ()
    }
    
    func setDisplayedDate(start: Date?, end: Date?) {
        guard let startTime = start, let endTime = end else {
            dateLabel.text = "Unspecified"
            return
        }
        let startYear = YEAR_FORMATTER.string(from: startTime)
        let endYear = YEAR_FORMATTER.string(from: endTime)
        let currentYear = YEAR_FORMATTER.string(from: Date())
        
        let startDay = DAY_FORMATTER.string(from: startTime)
        let endDay = DAY_FORMATTER.string(from: endTime)
        let today = DAY_FORMATTER.string(from: Date())
        
        let df1 = DateFormatter()
        df1.locale = Locale(identifier: "en_US")
        if startDay == today {
            df1.dateFormat = "'Today' h:mm a"
        } else if startYear == currentYear {
            df1.dateFormat = "MM-dd h:mm a"
        } else {
            df1.dateFormat = "y-MM-dd h:mm a"
        }
        
        let df2 = DateFormatter()
        df2.locale = Locale(identifier: "en_US")
        if startDay == endDay {
            df2.dateFormat = "h:mm a"
        } else if endDay == today {
            df2.dateFormat = "today h:mm a"
        } else if startYear == endYear {
            df2.dateFormat = "MM-dd h:mm a"
        } else {
            df2.dateFormat = "y-MM-dd h:mm a"
        }
        
        dateLabel.text = df1.string(from: startTime) + " ~ " + df2.string(from: endTime)
    }
    
    func setTime(for event: Event) {
        setDisplayedDate(start: event.startTime, end: event.endTime)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
