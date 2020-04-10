//
//  BannerInfo.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/4/8.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class BannerInfo: CustomStringConvertible {
    
    let title: String
    let message: String?
    let priority: Int
    let imageName: String?
    var hasImage: Bool?
    private(set) var loadError = false
    private(set) var isFetching = false
    let usesDarkImage: Bool
    var image: UIImage?
    let publishedDate: Date
    let link: URL?
    
    var imageFetchedHandler: ((Bool) -> ())?
    
    init(json: JSON) {
        let dictionary = json.dictionaryValue
        
        title = dictionary["Title"]?.string ?? "No title"
        message = dictionary["Message"]?.string
        imageName = dictionary["Image name"]?.string
        hasImage = imageName != nil
        priority = dictionary["Priority"]?.int ?? 100
        usesDarkImage = dictionary["Dark"]?.int == 1
        
        if let rawDate = dictionary["Published date"]?.string {
            publishedDate = DATE_FORMATTER.date(from: rawDate) ?? .distantPast
        } else {
            publishedDate = .distantPast
        }
        
        link = dictionary["Link"]?.url
    }
    
    func fetchImage() {
        
        loadError = false
        
        guard let imageName = imageName, hasImage == true else {
            DispatchQueue.main.async {
                self.imageFetchedHandler?(true)
            }
            return
        }
        
        guard image == nil else {
            DispatchQueue.main.async {
                self.imageFetchedHandler?(true)
            }
            return
        }
        
        isFetching = true
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetBannerImage",
                           parameters: ["imageName": imageName])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            self.isFetching = false
            
            guard error == nil else {
                self.loadError = true
                DispatchQueue.main.async {
                    self.imageFetchedHandler?(false)
                }
                return
            }
            
            if let data = UIImage(data: data!) {
                self.image = data
                DispatchQueue.main.async {
                    self.imageFetchedHandler?(true)
                }
            } else {
                self.loadError = true
                DispatchQueue.main.async {
                    self.imageFetchedHandler?(false)
                }
            }
            
        }
        
        task.resume()
    }
    
    
    var description: String {
        return "Banner(title: '\(title)')"
    }
    
}
