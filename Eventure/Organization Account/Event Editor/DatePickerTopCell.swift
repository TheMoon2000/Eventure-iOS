//
//  DatePickerTopCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/24.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DatePickerTopCell: UITableViewCell {
    
    let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    let longFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM. d, h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private var bgView: UIView!
    private(set) var leftLabel: UILabel!
    private(set) var indicator: UIView!
    private(set) var rightLabel: UILabel!
    
    var displayedDate = Date() {
        didSet {
            if YEAR_FORMATTER.string(from: Date()) != YEAR_FORMATTER.string(from: displayedDate) {
                rightLabel.text = longFormatter.string(from: displayedDate)
            } else {
                rightLabel.text = shortFormatter.string(from: displayedDate)
            }
        }
    }
    
    required init(title: String) {
        super.init(style: .default, reuseIdentifier: nil)
        
        backgroundColor = AppColors.background
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
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
        
        leftLabel = {
            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()

        indicator = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate))
            iv.tintColor = .lightGray
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 22).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 22).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            
            return iv
        }()
        
        rightLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.text = "No time selected"
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
            label.textColor = MAIN_TINT
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: 8).isActive = true
            label.rightAnchor.constraint(equalTo: indicator.leftAnchor, constant: -5).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            let t = label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 17)
            t.priority = .defaultLow
            t.isActive = true
            let b = label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -17)
            b.priority = .defaultLow
            b.isActive = true
            
            return label
        }()
    }
    
    func expand() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }
    
    func collapse() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
