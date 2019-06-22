//
//  MessageCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/6/21.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var caption: String = "" {
        didSet {
            let attrText = NSMutableAttributedString(string: caption)
            attrText.addAttributes(customAttributes,
                                   range: NSMakeRange(0, caption.count))
            captionTextView.attributedText = attrText
        }
    }
    
    private var titleLabel: UILabel!
    private var captionTextView: UITextView!
    
    private var customAttributes: [NSAttributedString.Key : Any] = {
        var attributes = [NSAttributedString.Key : Any]()
        
        let pgStyle = NSMutableParagraphStyle()
        pgStyle.lineSpacing = 3
        pgStyle.alignment = .center
        
        attributes[.font] = UIFont.systemFont(ofSize: 17.5)
        attributes[.paragraphStyle] = pgStyle
        attributes[.foregroundColor] = UIColor.gray
        
        return attributes
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        
        titleLabel = makeTitle()
        captionTextView = makeCaption()
    }
    
    private func makeTitle() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        return label
    }
    
    private func makeCaption() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                      constant: 10).isActive = true
        textView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: 30).isActive = true
        textView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                        constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                         constant: -10).isActive = true
        return textView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
