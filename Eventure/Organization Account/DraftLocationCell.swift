//
//  DraftLocationCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftLocationCell: UITableViewCell, UITextViewDelegate {

    private var bgView: UIView!
    private var locationLabel: UILabel!
    private var locationText: UITextView!
    private var baseline: UIView!
    
    var textChangeHandler: (() -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        locationLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.text = "Location:"
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        locationText = {
            let tv = UITextView()
            tv.font = .systemFont(ofSize: 17)
            tv.isScrollEnabled = false
            tv.delegate = self
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 5
            
            tv.typingAttributes = [
                NSAttributedString.Key.paragraphStyle: pStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)
            ]
            tv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            tv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5).isActive = true
            tv.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            tv.heightAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
            
            return tv
        }()
        
        baseline = {
            let view = UIView()
            view.backgroundColor = LINE_TINT
            view.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(view, belowSubview: locationText)
            
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            view.leftAnchor.constraint(equalTo: locationText.leftAnchor, constant: 2).isActive = true
            view.rightAnchor.constraint(equalTo: locationText.rightAnchor, constant: -2).isActive = true
            view.topAnchor.constraint(equalTo: locationText.bottomAnchor).isActive = true
            
            return view
        }()
        
        
    }

    func textViewDidChange(_ textView: UITextView) {
        textChangeHandler?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
