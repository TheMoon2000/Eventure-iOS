//
//  KeywordSuggestionCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/3/17.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class KeywordSuggestionCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var keywordTitle: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let v = UIView()
            v.backgroundColor = AppColors.background
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            v.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            v.topAnchor.constraint(equalTo: topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            return v
        }()
        
        keywordTitle = {
            let label = UILabel()
            label.font = .appFontMedium(18)
            label.numberOfLines = 3
            label.textColor = AppColors.keyword
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true
            
            return label
        }()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if !highlighted {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.bgView.backgroundColor = AppColors.background
            })
        } else {
            bgView.backgroundColor = highlighted ? AppColors.selected : AppColors.background
        }
    }

}
