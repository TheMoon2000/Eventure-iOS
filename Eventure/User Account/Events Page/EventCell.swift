//
//  EventCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {
    
    private let verticalSpacing: CGFloat = 14
    
    private var card: UIView!
    private var cover: UIImageView!
    
    private var timeLabel: UILabel!
    private var locationLabel: UILabel!
    private var eventHostLabel: UILabel!
    
    var titleText: UILabel!
    var timeText: UILabel!
    var locationText: UILabel!
    var eventHostText: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        card = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
            view.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            
            let right = view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10)
            right.priority = .init(999)
            right.isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            
            let bottom = view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
            bottom.priority = .defaultHigh
            bottom.isActive = true
            
            return view
        }()
        
        cover = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(iv)
            
            iv.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 1.5).isActive = true
            
            return iv
        }()
        
        titleText = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 21, weight: .bold)
            label.numberOfLines = 10
            label.textColor = .init(white: 0.1, alpha: 1)
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 18).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        func dot() -> UIView {
            let dot = UIView()
            dot.backgroundColor = .init(white: 0.85, alpha: 1)
            dot.layer.cornerRadius = 1.9
            dot.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(dot)
            dot.widthAnchor.constraint(equalToConstant: 3.8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 3.8).isActive = true
            dot.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 20).isActive = true
            return dot
        }
        
        let dot1 = dot()
        dot1.centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: -10).isActive = true
        
        dot().centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        
        dot().centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: 10).isActive = true
        
        timeLabel = {
            let label = UILabel()
            label.text = "When:"
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        timeText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textColor = .darkGray
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: dot1.bottomAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        locationLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.text = "Where:"
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            
            return label
        }()
        
        locationText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: locationLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: timeText.bottomAnchor, constant: verticalSpacing).isActive = true
            label.topAnchor.constraint(equalTo: locationLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        eventHostLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.text = "Hosted by:"
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.layoutIfNeeded()
            label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
            label.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -20).isActive = true

            return label
        }()
        
        eventHostText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: eventHostLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: locationText.bottomAnchor, constant: verticalSpacing).isActive = true
            label.topAnchor.constraint(equalTo: eventHostLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
    }
    
    
    func setupCellWithEvent(event: Event, withImage: Bool = false) {
        titleText.text = event.title
        timeText.text = event.timeDescription
        locationText.text = event.location
        eventHostText.text = event.hostTitle
        
        if event.eventVisual == nil {
            if withImage {
                event.getCover { eventWithCover in
                    self.setupCellWithEvent(event: eventWithCover)
                }
            }
            cover.image = #imageLiteral(resourceName: "cover_placeholder")
        } else {
            cover.image = event.eventVisual
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
