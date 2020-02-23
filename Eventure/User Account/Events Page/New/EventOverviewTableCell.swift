//
//  EventOverviewTableCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/20.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class EventOverviewTableCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var eventTitle: UILabel!
    private(set) var orgLogo: UIImageView!
    private var datetimeIcon: UIImageView!
    private(set) var dateTime: UILabel!
    private var locationIcon: UIImageView!
    private(set) var location: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.background
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
            
            return view
        }()
        
        orgLogo = {
            let logo = UIImageView()
            logo.clipsToBounds = true
            logo.layer.cornerRadius = 4
            logo.layer.masksToBounds = true
            logo.tintColor = AppColors.mainDisabled
            logo.contentMode = .scaleAspectFit
            logo.backgroundColor = AppColors.disabled
            // logo.layer.borderColor = AppColors.line.cgColor
            // logo.layer.borderWidth = 0.5
            logo.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(logo)
            
            logo.widthAnchor.constraint(equalToConstant: 36).isActive = true
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
            logo.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            logo.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 18).isActive = true
            
            return logo
        }()
        
        eventTitle = {
            let label = UILabel()
            label.font = .appFontSemibold(16)
            label.textColor = AppColors.label
            label.numberOfLines = 10
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: orgLogo.rightAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: orgLogo.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        datetimeIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "datetime").withRenderingMode(.alwaysTemplate))
            icon.tintColor = AppColors.lightControl
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(icon)
            
            icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 12).isActive = true
            
            return icon
        }()
        
        dateTime = {
            let label = UILabel()
            label.textColor = AppColors.prompt
            label.text = "Unspecified"
            label.font = .appFontRegular(15)
            label.numberOfLines = 10
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: datetimeIcon.rightAnchor, constant: 5).isActive = true
            label.topAnchor.constraint(equalTo: datetimeIcon.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            
            return label
        }()
        
        locationIcon = {
            let icon = UIImageView(image: #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate))
            icon.tintColor = AppColors.lightControl
            icon.contentMode = .scaleAspectFit
            icon.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(icon)
            
            icon.widthAnchor.constraint(equalTo: datetimeIcon.widthAnchor).isActive = true
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: dateTime.bottomAnchor, constant: 8).isActive = true
            
            return icon
        }()
        
        
        location = {
            let label = UILabel()
            label.textColor = AppColors.prompt
            label.text = "Unspecified"
            label.font = .appFontRegular(15)
            label.numberOfLines = 10
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: locationIcon.rightAnchor, constant: 5).isActive = true
            label.topAnchor.constraint(equalTo: locationIcon.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: eventTitle.rightAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -18).isActive = true
           
           return label
       }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /*
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            bgView.backgroundColor = AppColors.selected
        } else {
            UIView.animate(withDuration: 0.2) {
                self.bgView.backgroundColor = AppColors.background
            }
        }
    }*/

}
