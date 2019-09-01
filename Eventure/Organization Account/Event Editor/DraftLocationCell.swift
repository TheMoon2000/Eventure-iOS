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
    private(set) var locationText: UITextView!
    private var placeholder: UILabel!
    private var baseline: UIView!
    
    var textChangeHandler: ((String) -> ())?
    
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
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        locationText = {
            let tv = UITextView()
            tv.font = .systemFont(ofSize: 17)
            tv.isScrollEnabled = false
            tv.delegate = self
            tv.backgroundColor = .clear
            tv.keyboardDismissMode = .onDrag
            tv.textContainer.lineFragmentPadding = 0
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 5
            
            tv.typingAttributes = [
                NSAttributedString.Key.paragraphStyle: pStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor: MAIN_TINT_DARK
            ]
            tv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            tv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5).isActive = true
            tv.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
            
            return tv
        }()
        
        placeholder = {
            let label = UILabel()
            label.text = "e.g. HP Auditorium, online"
            label.textColor = .lightGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(label, belowSubview: locationText)
            
            label.leftAnchor.constraint(equalTo: locationText.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: locationText.topAnchor, constant: 8).isActive = true
            
            return label
        }()
        
        baseline = {
            let view = UIView()
            view.backgroundColor = LINE_TINT
            view.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(view, belowSubview: locationText)
            
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            view.leftAnchor.constraint(equalTo: locationText.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: locationText.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: locationText.bottomAnchor).isActive = true
            
            return view
        }()
        
        
    }

    func textViewDidChange(_ textView: UITextView) {
        textChangeHandler?(textView.text)
        placeholder.isHidden = !textView.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
