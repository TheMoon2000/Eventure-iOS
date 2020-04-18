//
//  PopularEventsPreview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/13.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

private let reuseIdentifier = "Cell"

class PopularEventsPreview: UICollectionViewController {
    
    private var loader: UIActivityIndicatorView!
    private var popularEvents = [Event]()
    
    /// Delegate object for handling loading events.
    var finishedLoadingHandler: ((Status) -> ())?
    
    enum Status: Int {
        case success, error, nothing
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
        let newLayout = UICollectionViewFlowLayout()
        newLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: newLayout)
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset.left = 20
        collectionView.contentInset.right = 20
        collectionView.showsHorizontalScrollIndicator = false
        
        // Register cell classes
        self.collectionView!.register(EventPreviewCell.self, forCellWithReuseIdentifier: "event")
        
        getPopularEvents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("this line should never be printed")
    }

    
    func getPopularEvents() {
        
        var parameters = [String: String]()
        if let user = User.current {
            parameters["userEmail"] = user.email
            parameters["userId"] = String(user.userID)
        }
        
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/PopularEvents",
                           parameters: parameters)!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.finishedLoadingHandler?(.error)
                }
                return
            }
            
            if let json = try? JSON(data: data!).arrayValue {
                var tmp = [Event]()
                for eventData in json {
                    let newEvent = Event(eventInfo: eventData)
                    if newEvent.isPublic || (User.current?.memberships.contains { $0.orgID == newEvent.hostID } ?? false) {
                        tmp.append(newEvent)
                    }
                }
                self.popularEvents = tmp.sorted(by: { (e1: Event, e2: Event) -> Bool in
                    return e1.interested.count > e2.interested.count || e1.views > e2.views || e1.title < e2.title
                })
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    if tmp.isEmpty {
                        self.finishedLoadingHandler?(.nothing)
                    } else {
                        self.finishedLoadingHandler?(.success)
                    }
                }
            }
        }
        
        task.resume()
    }
    
}

extension PopularEventsPreview {
    
    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularEvents.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: indexPath) as! EventPreviewCell
        
        let event = popularEvents[indexPath.row]
        
        Organization.getLogoImage(orgID: event.hostID) { image in
            if image == UIImage.empty {
                cell.orgLogo.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            } else {
                cell.orgLogo.image = image ?? #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
            }
        }
        
        cell.eventTitle.text = event.title
        cell.startTime.text = event.timeDescription
        cell.location.text = event.location
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailPage = EventDetailPage()
        detailPage.interestedStatusChanged = { status in
            print(status)
        }
        detailPage.event = popularEvents[indexPath.row]
        detailPage.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailPage, animated: true)
    }

}


extension PopularEventsPreview: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 245, height: 135)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
