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
    
    private var titleLabel: UILabel!
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
            view.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
            
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
        
        titleLabel = {
            let label = UILabel()
            label.text = "Title:"
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 41).isActive = true
            
            return label
        }()
        
        titleText = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        timeLabel = {
            let label = UILabel()
            label.text = "When:"
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
            
            return label
        }()
        
        timeText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: verticalSpacing).isActive = true
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
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 87).isActive = true
            
            return label
        }()
        
        locationText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
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
            label.widthAnchor.constraint(equalToConstant: 87).isActive = true

            return label
        }()
        
        eventHostText = {
            let label = UILabel()
            label.numberOfLines = 5
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .right
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
    
    
    func setupCellWithEvent(event: Event) {
        titleText.text = event.title
        timeText.text = event.timeDescription
        locationText.text = event.location
        eventHostText.text = event.hostTitle
        cover.image = event.eventVisual ?? #imageLiteral(resourceName: "cover_placeholder")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
