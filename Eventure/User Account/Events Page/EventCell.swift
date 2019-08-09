//
//  EventCell.swift
//  Eventure
//
//  Created by Xiang Li on 8/7/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    static let height = 200
    private var bgTint: UIView!
    private var eventView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "cell")
        
        makeCell()
    }
    
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    if self.isSelected {
                        self.bgTint.backgroundColor = MAIN_TINT_DARK
                    } else {
                        self.bgTint.backgroundColor = MAIN_TINT
                    }
            },
                completion: nil)
        }
    }
    
    private func makeCell() {
        bgTint = {
            let bg = UIView()
            bg.backgroundColor = MAIN_TINT
            bg.layer.cornerRadius = 0
            bg.layer.borderWidth = 1.5
            bg.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
            bg.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bg)
            
            bg.heightAnchor.constraint(equalToConstant: CGFloat(EventCell.height)).isActive = true
            bg.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            bg.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            bg.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            return bg
        }()
        
        eventView = {
            let ev = UIView()
            ev.backgroundColor = .white
            ev.tintColor = MAIN_TINT
            ev.translatesAutoresizingMaskIntoConstraints = false
            bgTint.addSubview(ev)
            
            ev.heightAnchor.constraint(equalTo: bgTint.heightAnchor, constant: -60).isActive = true
            ev.bottomAnchor.constraint(equalTo: bgTint.bottomAnchor).isActive = true
            ev.centerXAnchor.constraint(equalTo: bgTint.centerXAnchor).isActive = true
            ev.widthAnchor.constraint(equalTo: bgTint.widthAnchor).isActive = true
            
            return ev
        }()
        
    }
    
    func makeEvent(e: Event) {
        var vals = ["title": e.title, "time": e.time, "location": e.location, "hostTitle": e.host.title]
        let textViews = ["title":UITextView(), "time": UITextView(), "location": UITextView(), "hostTitle": UITextView()]
        for v in textViews {
            v.value.allowsEditingTextAttributes = false
            v.value.isEditable = false
            v.value.translatesAutoresizingMaskIntoConstraints = false
            v.value.text = v.key + ": " + vals[v.key]!
            v.value.font = UIFont.preferredFont(forTextStyle: .subheadline)
            v.value.doInset()
            v.value.textColor = .black
            eventView.addSubview(v.value)
            v.value.widthAnchor.constraint(equalTo: eventView.widthAnchor).isActive = true
            v.value.leftAnchor.constraint(equalTo: eventView.leftAnchor).isActive = true
            v.value.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        textViews["title"]!.centerYAnchor.constraint(equalTo: eventView.topAnchor, constant: 20).isActive = true
        textViews["time"]!.topAnchor.constraint(equalTo: textViews["title"]!.bottomAnchor).isActive = true
        textViews["location"]!.topAnchor.constraint(equalTo: textViews["time"]!.bottomAnchor).isActive = true
        textViews["hostTitle"]!.topAnchor.constraint(equalTo: textViews["location"]!.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
