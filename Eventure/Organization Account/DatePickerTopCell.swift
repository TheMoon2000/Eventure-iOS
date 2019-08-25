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

    private var bgView: UIView!
    private var leftLabel: UILabel!
    private var rightLabel: UILabel!
    
    var displayedDate = Date() {
        didSet {
            rightLabel.text = shortFormatter.string(from: displayedDate)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            view.heightAnchor.constraint(equalToConstant: 48).isActive = true
            
            return view
        }()
        
        leftLabel = {
            let label = UILabel()
            label.text = "Start time:"
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        rightLabel = {
            let label = UILabel()
            label.text = shortFormatter.string(from: Date())
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
            label.textColor = MAIN_TINT
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: 8).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        bgView.backgroundColor = highlighted ? UIColor(white: 0.97, alpha: 1) : .white
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
