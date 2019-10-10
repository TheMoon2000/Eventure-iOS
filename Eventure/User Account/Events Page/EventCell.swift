//
//  EventCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {
        
    private var event: Event!
    
    private var card: UIView!
    private var cover: UIImageView!
    private var interestBG: UIView!
    private(set) var interestedButton: UIButton!
    
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
            view.backgroundColor = AppColors.card
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
            view.layer.borderColor = AppColors.line.cgColor
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
        
        interestedButton = {
            let button = UIButton(type: .system)
            button.isHidden = User.current == nil
            button.imageView?.contentMode = .scaleAspectFit
            button.tintColor = MAIN_TINT
            button.setImage(#imageLiteral(resourceName: "star_empty").withRenderingMode(.alwaysTemplate), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            button.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -12).isActive = true
            button.topAnchor.constraint(equalTo: card.topAnchor, constant: 12).isActive = true
            button.widthAnchor.constraint(equalToConstant: 25).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            
            button.addTarget(self, action: #selector(toggleInterested), for: .touchUpInside)
            
            return button
        }()
        
        interestBG = {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            view.alpha = 0.7
            view.isHidden = User.current == nil
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(view)
            
            view.topAnchor.constraint(equalTo: card.topAnchor, constant: -10).isActive = true
            view.rightAnchor.constraint(equalTo: card.rightAnchor, constant: 10).isActive = true
            view.widthAnchor.constraint(equalToConstant: 60).isActive = true
            view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            
            return view
        }()
        
        
        titleText = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 21, weight: .bold)
            label.numberOfLines = 10
            label.textColor = AppColors.label
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
            label.textColor = AppColors.prompt
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
            label.textColor = AppColors.value
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
            label.textColor = AppColors.prompt
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
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: locationLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: timeText.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.topAnchor.constraint(equalTo: locationLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        eventHostLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.text = "Hosted by:"
            label.textColor = AppColors.prompt
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
            label.textColor = AppColors.value
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: eventHostLabel.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: locationText.bottomAnchor, constant: VERTICAL_SPACING).isActive = true
            label.topAnchor.constraint(equalTo: eventHostLabel.topAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        card.layer.borderColor = AppColors.line.cgColor
    }
    
    @objc private func toggleInterested() {
        let isInterested = toggle()
        
        User.current?.syncInterested(interested: isInterested, for: event, completion: nil)
    }
    
    private func toggle() -> Bool {
        UISelectionFeedbackGenerator().selectionChanged()
        if !User.current!.interestedEvents.contains(event.uuid) {
            interestedButton.setImage(#imageLiteral(resourceName: "star_filled"), for: .normal)
            User.current?.interestedEvents.insert(event.uuid)
            return true
        } else {
            interestedButton.setImage(#imageLiteral(resourceName: "star_empty"), for: .normal)
            User.current?.interestedEvents.remove(event.uuid)
            return false
        }
    }
    
    func setupCellWithEvent(event: Event, withImage: Bool = false) {
        self.event = event
        titleText.text = event.title
        timeText.text = event.timeDescription
        locationText.text = event.location
        eventHostText.text = event.hostTitle
        
        if User.current == nil {
            interestedButton.setImage(#imageLiteral(resourceName: "star_empty").withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            if User.current!.interestedEvents.contains(event.uuid) {
                interestedButton.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                interestedButton.setImage(#imageLiteral(resourceName: "star_empty").withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        if event.eventVisual == nil {
            if withImage {
                event.getCover { [weak self] eventWithCover in
                    self?.setupCellWithEvent(event: eventWithCover)
                }
            }
            cover.image = #imageLiteral(resourceName: "berkeley")
        } else {
            cover.image = event.eventVisual
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
