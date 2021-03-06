//
//  MessageSenderCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class MessageSenderCell: UITableViewCell {
    
    static let PREVIEW_STYLE = """
        body {
            font-family: "Proxima Nova";
            font-size: 15.5px;
            line-height: 1.25;
            letter-spacing: 1%;
            color: #6A6A6A;
            margin-bottom: 10px;
        }
        strong, em {
            color: #505050;
        }
"""

    private(set) var senderLogo: UIImageView!
    private(set) var senderTitle: UILabel!
    private var messageOverview: UILabel!
    private(set) var badge: BadgeCount!
    private(set) var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = AppColors.background
        
        senderLogo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate))
            iv.tintColor = MAIN_DISABLED
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 5
            iv.layer.masksToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 42).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 14).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        dateLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.font = .appFontRegular(13)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 18.5).isActive = true
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            return label
        }()
        
        senderTitle = {
            let label = UILabel()
            label.numberOfLines = 3
            label.textColor = AppColors.label
            label.font = .appFontMedium(18)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: senderLogo.rightAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: -13).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }()
        
        messageOverview = {
            let label = UILabel()
            label.font = .appFontRegular(15)
            label.numberOfLines = 2
            label.textColor = AppColors.prompt
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: senderTitle.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true
            label.topAnchor.constraint(equalTo: senderTitle.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        badge = {
            let badge = BadgeCount()
            badge.translatesAutoresizingMaskIntoConstraints = false
            addSubview(badge)
            
            badge.rightAnchor.constraint(equalTo: senderLogo.rightAnchor, constant: 10).isActive = true
            badge.centerYAnchor.constraint(equalTo: senderLogo.topAnchor).isActive = true
            
            return badge
        }()
        
        
    }
    
    func setup(content: AccountNotification) {
        senderTitle.text = content.sender.name
        
        let attributedContent = NSMutableAttributedString(attributedString: content.shortString)
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineBreakMode = .byTruncatingTail
        attributedContent.addAttribute(.paragraphStyle, value: pStyle, range: NSMakeRange(0, attributedContent.length))
            
        messageOverview.attributedText = attributedContent
        messageOverview.textColor = AppColors.prompt
        
        dateLabel.text = content.creationDate.shortString
        
        if content.senderLogo != nil {
            senderLogo.image = content.senderLogo
        } else {
            content.getLogoImage { image in
                self.senderLogo.image = image
            }
        }
    }
    
    func setPreview(string: String) {
        messageOverview.attributedText = string.attributedText(style: MessageSenderCell.PREVIEW_STYLE)
        messageOverview.textColor = AppColors.prompt
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        badge.backgroundColor = AppColors.badgeColor
        badge.layer.cornerRadius = 9
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
