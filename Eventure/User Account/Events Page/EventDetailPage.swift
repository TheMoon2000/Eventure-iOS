//
//  EventDetailPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventDetailPage: UIViewController {
    
    static let standardAttributes: [NSAttributedString.Key : Any] = {
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.lineSpacing = 5.0
        pStyle.paragraphSpacing = 12.0
        
        return [
            NSAttributedString.Key.paragraphStyle: pStyle,
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.5),
            NSAttributedString.Key.kern: 0.2
        ]
    }()
    
    /// The event which the current view controller displays.
    var event: Event!
    
    private var hideBlankImages = true
    
    private var canvas: UIScrollView!
    private var coverImage: UIImageView!
    private var eventTitle: UILabel!
    private var favoriteButton: UIBarButtonItem!
    private var eventDescription: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Event Details"
        view.backgroundColor = .white
        
        favoriteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "heart_empty"), style: .plain, target: self, action: #selector(changedFavoriteStatus))
        favoriteButton.isEnabled = User.current != nil
        navigationItem.rightBarButtonItem = favoriteButton

        canvas = {
            let canvas = UIScrollView()
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            canvas.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            canvas.contentInsetAdjustmentBehavior = .always
            
            return canvas
        }()
        
        
        coverImage = {
            let iv = UIImageView(image: event.eventVisual)
            if hideBlankImages && event.eventVisual == nil {
                iv.isHidden = true
            }
            iv.backgroundColor = MAIN_DISABLED
            iv.contentMode = .scaleAspectFill
            iv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(iv)
            
            iv.topAnchor.constraint(lessThanOrEqualTo: canvas.topAnchor).isActive = true
            iv.widthAnchor.constraint(equalTo: iv.heightAnchor, multiplier: 1.5).isActive = true
            iv.centerXAnchor.constraint(equalTo: canvas.centerXAnchor).isActive = true
            iv.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
            let left = iv.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor)
            left.priority = .defaultHigh
            left.isActive = true
            
            let right = iv.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor)
            right.priority = .defaultHigh
            right.isActive = true
            
            return iv
        }()
        
        eventTitle = {
            let label = UILabel()
            label.numberOfLines = 10
            label.lineBreakMode = .byWordWrapping
            label.text = event.title
            label.font = .systemFont(ofSize: 20, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            
            if coverImage.isHidden {
                label.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 25).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 25).isActive = true
            }

            return label
        }()
        
        /*
        favoriteButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "star_empty"), for: .normal)
            button.tintColor = MAIN_TINT
            button.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(button)
            
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            button.centerYAnchor.constraint(equalTo: eventTitle.centerYAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            button.leftAnchor.constraint(equalTo: eventTitle.rightAnchor, constant: 20).isActive = true
            
            button.addTarget(self, action: #selector(changedFavoriteStatus), for: .touchUpInside)
            
            return button
        }()*/
        
        
        let line: UIView = {
            let line = UIView()
            line.backgroundColor = LINE_TINT
            line.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(line)
            
            line.leftAnchor.constraint(equalTo: eventTitle.leftAnchor).isActive = true
            line.topAnchor.constraint(equalTo: eventTitle.bottomAnchor, constant: 15).isActive = true
            line.widthAnchor.constraint(equalToConstant: 80).isActive = true
            line.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return line
        }()
        
        eventDescription = {
            let tv = UITextView()
            tv.attributedText = event.eventDescription.attributedText()
            tv.textContainerInset = .zero
            tv.textContainer.lineFragmentPadding = 0
            tv.dataDetectorTypes = .link
            tv.linkTextAttributes[.foregroundColor] = LINK_COLOR
            tv.isEditable = false
            tv.isScrollEnabled = false
            tv.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            tv.rightAnchor.constraint(equalTo: canvas.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            tv.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 15).isActive = true
            tv.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -40).isActive = true
            
            return tv
        }()
    }
    
    @objc private func changedFavoriteStatus() {
        
        guard let currentUser = User.current else {
            return
        }
        
        let isFavoriteOriginally = currentUser.favoritedEvents.contains(event.uuid)
        
        func toggle(_ update: Bool = true) {
            if favoriteButton.image == #imageLiteral(resourceName: "heart_empty") {
                favoriteButton.image = #imageLiteral(resourceName: "heart")
            } else {
                favoriteButton.image = #imageLiteral(resourceName: "heart_empty")
            }
            if update {
                if isFavoriteOriginally {
                    currentUser.favoritedEvents.remove(event.uuid)
                } else {
                    currentUser.favoritedEvents.insert(event.uuid)
                }
            } else {
                if isFavoriteOriginally {
                    currentUser.favoritedEvents.insert(event.uuid)
                } else {
                    currentUser.favoritedEvents.remove(event.uuid)
                }
            }
        }
        
        toggle()
        
        let parameters = [
            "userId": String(currentUser.uuid),
            "eventId": event.uuid,
            "favorited": favoriteButton.image == #imageLiteral(resourceName: "heart") ? "1" : "0"
        ]
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/MarkEvent",
                           parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    internetUnavailableError(vc: self) { toggle() }
                }
                return
            }
            
            let msg = String(data: data!, encoding: .utf8) ?? INTERNAL_ERROR
            
            if msg == INTERNAL_ERROR {
                DispatchQueue.main.async {
                    serverMaintenanceError(vc: self) { toggle() }
                }
            }
        }
        
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
