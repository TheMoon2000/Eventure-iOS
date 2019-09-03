//
//  EventCell.swift
//  Eventure
//
//  Created by Xiang Li on 8/7/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCell2: UITableViewCell {
    
    var event: Event!
    
    private var card: UIView!
    private var compositeStack: UIStackView!
    private var cover: UIImageView!
    private var eventView: UIView!
    
    private var titleLabel: UILabel!
    private var timeLabel: UILabel!
    private var locationLabel: UILabel!
    private var eventHostLabel: UILabel!
    
    var titleText: UILabel!
    var timeText: UILabel!
    var locationText: UILabel!
    var eventHostText: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(event: Event) {
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        backgroundColor = .clear
        self.event = event
        makeCell()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                if highlighted {
                    self.card.backgroundColor = UIColor(white: 0.9, alpha: 1)
                } else {
                    self.card.backgroundColor = .white
                }
        },
            completion: nil)
    }
    
    
    private func makeCell() {
        
        card = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
            
            return view
        }()
        
        
        eventView = {
            let ev = UIView()
            ev.backgroundColor = .clear
//            ev.tintColor = MAIN_TINT
            ev.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
            ev.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
            
            return ev
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Title:"
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        titleText = {
            let label = UILabel()
            label.text = event.title
            label.font = .systemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
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
}
