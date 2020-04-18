//
//  AnnouncementHistoryCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/16.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import BonMot

class AnnouncementHistoryCell: UITableViewCell {

    private var titleLabel: UILabel!
    private(set) var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        backgroundColor = AppColors.background
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        dateLabel = {
            let label = UILabel()
            label.font = .appFontRegular(15)
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            
            return label
        }()
    }
    
    func setTitle(title: String, sender: String) {
        titleLabel.attributedText = .composed(of: [
            sender.styled(with:
                .color(AppColors.emphasis),
                .font(.appFontSemibold(16))
            ),
            " - ".styled(with:
                .color(AppColors.prompt),
                .font(.appFontRegular(16))
            ),
            title.styled(with:
                .color(AppColors.label),
                .font(.appFontMedium(16))
            )
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
