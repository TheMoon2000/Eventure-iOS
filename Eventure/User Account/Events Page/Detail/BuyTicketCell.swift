//
//  BuyTicketCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class BuyTicketCell: UITableViewCell {
    
    private(set) var admissionType: AdmissionType!
    
    private var bgView: UIView!
    private(set) var ticketName: UILabel!
    private(set) var ticketPrice: UILabel!
    private(set) var buyButton: UIButton!
    
    var buyHandler: ((AdmissionType) -> ())?

    required init(admissionType: AdmissionType) {
        super.init(style: .default, reuseIdentifier: nil)
        
        self.admissionType = admissionType
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
                        
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        ticketName = {
            let label = UILabel()
            label.numberOfLines = 0
            label.text = admissionType.typeName
            label.textColor = AppColors.label
            label.font = .appFontMedium(18)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 18).isActive = true
            
            return label
        }()
        
        ticketPrice = {
            let label = UILabel()
            label.numberOfLines = 5
            label.text = "$" + admissionType.priceDescription
            label.font = .appFontRegular(15)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: ticketName.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: ticketName.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -18).isActive = true
            
            return label
        }()
        
        buyButton = {
            let button = UIButton(type: .system)
            if (admissionType.quota ?? 0) != 0 && admissionType.quota! <= admissionType.quantitySold {
                button.setTitle("Sold out", for: .normal)
                button.isUserInteractionEnabled = false
                button.backgroundColor = AppColors.mainDisabled
            } else {
                button.setTitle("Buy", for: .normal)
                button.backgroundColor = AppColors.main
            }
            button.tintColor = .white
            button.contentEdgeInsets.left = 16
            button.contentEdgeInsets.right = 16
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .appFontSemibold(16)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            bgView.addSubview(button)
            
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.leftAnchor.constraint(equalTo: ticketName.rightAnchor, constant: 20).isActive = true
            button.leftAnchor.constraint(equalTo: ticketPrice.rightAnchor, constant: 20).isActive = true
            button.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            button.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            return button
        }()
    }
    
    @objc private func buttonPressed() {
        buyHandler?(admissionType)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.subview
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
