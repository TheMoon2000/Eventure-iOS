//
//  RequestCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    
    private var bgView: UIView!
    private var message: UILabel!
    private var acceptButton: UIButton!
    private var declineButton: UIButton!
    
    var acceptHandler: (() -> ())?
    var declineHandler: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        message = {
            let label = UILabel()
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        acceptButton = {
            let button = UIButton(type: .system)
            button.setTitle("Accept", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.tintColor = PASSED_COLOR
            button.layer.borderColor = PASSED_COLOR.cgColor
            button.backgroundColor = PASSED_COLOR.withAlphaComponent(0.2)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: bgView.leftAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier: 0.5).isActive = true
            button.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            
            button.addTarget(self, action: #selector(accept), for: .touchUpInside)
            
            return button
        }()
        
        declineButton = {
            let button = UIButton(type: .system)
            button.setTitle("Decline", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.tintColor = FATAL_COLOR
            button.layer.borderColor = FATAL_COLOR.cgColor
            button.backgroundColor = FATAL_COLOR.withAlphaComponent(0.2)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: acceptButton.rightAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: bgView.rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bgView.bottomAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            
            button.addTarget(self, action: #selector(reject), for: .touchUpInside)
            
            return button
        }()
    }
    
    @objc private func accept() {
        acceptHandler?()
    }
    
    @objc private func reject() {
        declineHandler?()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
