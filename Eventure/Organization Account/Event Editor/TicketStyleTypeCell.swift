//
//  TicketStyleTypeCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketStyleTypeCell: UITableViewCell {

    private var bgView: UIView!
    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private(set) var stack: UIStackView!
    private(set) var layoutPreview: UIImageView!
    private(set) var img: UIImageView!
    
    var variableConstraints = [NSLayoutConstraint]()
    
    var layoutType: Event.QRStyle = .standard {
        didSet {
            switch layoutType {
            case .imageBelow:
                layoutPreview.image = #imageLiteral(resourceName: "image below layout").withRenderingMode(.alwaysTemplate)
                titleLabel.text = "Image below"
                subtitleLabel.attributedText = "This layout style allows you to place a custom image below each ticket that you generate. There will be no text above the QR code. Ticket type is shown between the QR code and your image.".attributedText(style: COMPACT_STYLE)
            case .standard:
                layoutPreview.image = #imageLiteral(resourceName: "standard layout").withRenderingMode(.alwaysTemplate)
                titleLabel.text = "Standard layout"
                subtitleLabel.attributedText = "The standard layout displays the event title, time of the event, and location of the event above the QR code. Ticket type is shown at the bottom of the code.".attributedText(style: COMPACT_STYLE)
            }
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = AppColors.prompt
        }
    }
    
    var checked = false {
        didSet {
            img.isHidden = !checked
            bgView.backgroundColor = checked ? AppColors.selected : AppColors.subview
        }
    }
    
    var visible = false {
        didSet {
            layoutPreview.alpha = self.visible ? 1.0 : 0.0
            img.alpha = self.visible ? 1.0 : 0.0
            stack.alpha = self.visible ? 1.0 : 0.0
            variableConstraints.forEach { $0.isActive = self.visible }
        }
    }

    init(position: Position) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.applyMildShadow()
            if position == .top {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if position == .bottom {
                view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                view.layer.maskedCorners = []
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            
            let topConstant: CGFloat = position == .top ? 2 : 0.5

            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topConstant).isActive = true
            
            let h = view.heightAnchor.constraint(equalToConstant: 55)
            h.priority = .defaultLow
            h.isActive = true
            
            let bottomConstant: CGFloat = position == .bottom ? -10 : -0.5
            
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        layoutPreview = {
            let iv = UIImageView()
            iv.tintColor = .lightGray
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 50).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 60).isActive = true
            iv.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            let t = iv.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 10)
            t.priority = .defaultHigh
            variableConstraints.append(t)
            
            let b = iv.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -10)
            b.priority = .defaultHigh
            variableConstraints.append(b)
            
            return iv
        }()
        
        titleLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.textColor = AppColors.prompt
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        img = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate))
            iv.tintColor = AppColors.main
            iv.isHidden = true
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 24).isActive = true
            iv.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -12).isActive = true
            
            return iv
        }()
        
        stack = {
            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 6
            stack.alignment = .leading
            stack.distribution = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(stack)
            
            let t = stack.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 18)
            t.priority = .defaultHigh
            variableConstraints.append(t)
            
            let b = stack.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -18)
            b.priority = .defaultHigh
            variableConstraints.append(b)
            
            stack.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            stack.leftAnchor.constraint(equalTo: layoutPreview.rightAnchor, constant: 15).isActive = true
            stack.rightAnchor.constraint(equalTo: img.leftAnchor, constant: -10).isActive = true
            
            return stack
        }()
        
        layoutType = .standard
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    enum Position {
        case top, middle, bottom
    }
}
