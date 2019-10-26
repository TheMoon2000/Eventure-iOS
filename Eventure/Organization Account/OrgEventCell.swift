//
//  OrgEventCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SafariServices

class OrgEventCell: UICollectionViewCell {
    
    private var verticalSpacing: CGFloat = 14
    
    private var event: Event!
    var parentVC: UIViewController?
    
    private var card: UIView!
    private var cover: UIImageView!
    
    private var titleLabel: UILabel!
    private var timeLabel: UILabel!
    private var locationLabel: UILabel!
    private var descriptionText: TTTAttributedLabel!
    
    var titleText: UILabel!
    var timeText: UILabel!
    var locationText: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        card = {
            let view = UIView()
            view.backgroundColor = AppColors.card
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
            view.layer.borderColor = AppColors.line.cgColor
            view.applyMildShadow()
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
        
        func dot() -> UIView {
            let dot = UIView()
            dot.backgroundColor = .init(white: 0.85, alpha: 1)
            dot.layer.cornerRadius = 1.9
            dot.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(dot)
            dot.widthAnchor.constraint(equalToConstant: 3.8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 3.8).isActive = true
            dot.topAnchor.constraint(equalTo: locationText.bottomAnchor, constant: verticalSpacing).isActive = true
            return dot
        }
        
        let dot1 = dot()
        dot1.centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: -10).isActive = true
        
        dot().centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        
        dot().centerXAnchor.constraint(equalTo: card.centerXAnchor, constant: 10).isActive = true
        
        
        descriptionText = {
            let label = TTTAttributedLabel(frame: .zero)
            label.delegate = self
            label.numberOfLines = 3
            label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue +
                NSTextCheckingResult.CheckingType.phoneNumber.rawValue
            
            
            let attributes: [NSAttributedString.Key : Any] = [
                .foregroundColor: AppColors.link,
                .underlineStyle: true
            ]
            label.linkAttributes = attributes
            label.activeLinkAttributes = attributes
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: dot1.bottomAnchor, constant: verticalSpacing).isActive = true
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
    }
    
    
    func setupCellWithEvent(event: Event, withImage: Bool = false) {
        self.event = event
        titleText.text = event.title.isEmpty ? "Untitled" : event.title
        timeText.text = event.timeDescription
        locationText.text = event.location.isEmpty ? "TBA" : event.location
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            descriptionText.setText(event.eventDescription.attributedText(style: PLAIN_DARK))
            if event.eventDescription.isEmpty {
                descriptionText.setText("No description.".attributedText(style: PLAIN_DARK))
            }
        } else {
            descriptionText.setText(event.eventDescription.attributedText())
            if event.eventDescription.isEmpty {
                descriptionText.setText("No description.".attributedText())
            }
        }
        
        if event.eventVisual == nil {
            if withImage {
                if event.hasVisual {
                    cover.image = #imageLiteral(resourceName: "cover_placeholder")
                    event.getCover { [weak self] eventWithCover in
                        if let image = eventWithCover.eventVisual {
                            self?.cover.image = image
                        }
                    }
                } else {
                    cover.image = #imageLiteral(resourceName: "berkeley")
                }
            }
        } else {
            cover.image = event.eventVisual
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState != .background else { return }
        
        card.layer.borderColor = AppColors.line.cgColor
        
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            descriptionText.setText(event.eventDescription.attributedText(style: PLAIN_DARK))
        } else {
                descriptionText.setText(event.eventDescription.attributedText())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


extension OrgEventCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let alert = UIAlertController(title: "Open Link?", message: "You will be redirected to " + url.absoluteString, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Go", style: .default, handler: { action in
            let vc = SFSafariViewController(url: url)
            self.parentVC?.present(vc, animated: true)
        }))
        parentVC?.present(alert, animated: true, completion: nil)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith result: NSTextCheckingResult!) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch result.resultType {
        case NSTextCheckingResult.CheckingType.phoneNumber:
            let url = URL(string: "tel://" + result.phoneNumber!)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            break
        }
        parentVC?.present(alert, animated: true, completion: nil)
    }
    
}
