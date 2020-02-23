//
//  CategoryCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/10.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    private var title: UILabel!
    var category: Tag? {
        didSet {
            title.text = category?.name
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title = {
            let label = UILabel()
            label.text = "[Replace me]"
            label.font = .appFontRegular(18)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
