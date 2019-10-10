//
//  CommentCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell, UITextViewDelegate {
    
    var icon: UIImageView!
    private(set) var commentText: UITextView!
    private var placeholder: UILabel!

    var textChangeHandler: ((UITextView) -> ())?
    var textEndEditingHandler: ((String) -> ())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let h = heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        h.priority = .defaultHigh
        h.isActive = true
        
        backgroundColor = AppColors.background
        
        icon = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "comments"))
            iv.tintColor = MAIN_TINT
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 18).isActive = true
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            
            return iv
        }()

        commentText = {
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
            ]
            tv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
            tv.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            tv.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
            
            return tv
        }()
        
        placeholder = {
            let label = UILabel()
            label.text = "Additional information"
            label.textColor = .init(white: 0.79, alpha: 1)
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(label, belowSubview: commentText)
            
            label.leftAnchor.constraint(equalTo: commentText.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: commentText.topAnchor, constant: 8).isActive = true
            
            return label
        }()
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChangeHandler?(textView)
        placeholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textEndEditingHandler?(textView.text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
