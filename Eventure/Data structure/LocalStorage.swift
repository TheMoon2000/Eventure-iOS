//
//  LocalCache.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/21.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// A class designated for storing cached information.
class LocalStorage {
    
    static var CACHE_PATH = ACCOUNT_DIR.path + "/" + "LocalStorage"
    
    /// Internal representation of the local storage.
    static var rawCache = [String: Any]()
    
    /// Maps tag IDs to Tag objects.
    static var tags = [Int: Tag]()
    
    /// Maps tag IDs to tag logo images. This is stored as an extra copy from rawCache.
    static var tagImages = [Int: UIImage]()
    
    /// The keywords for event searching.
    static var keywords = [String]()
    
    /// Maps tag image requests to the time of the request.
    static var concurrentRequests = [Int: Date]()
    
    /// Maps major IDs to `Major` objects.
    static var majors = [Int: Major]()
    
    private init() {}
    
    /// This method should be called when the app launches to read from the cache.
    static func recoverFromCache() {
        let fileData = (NSKeyedUnarchiver.unarchiveObject(withFile: CACHE_PATH) as? [String: Any]) ?? [:]
                
        rawCache = fileData
        
        if let majorData = fileData["Majors"] as? [Int: Any] {
            for cachedMajor in majorData {
                if let data = try? JSON(data: cachedMajor.value as! Data) {
                    majors[cachedMajor.key] = Major(json: data)
                }
            }
            print("Loaded \(majors.count) majors from local cache")
        } else {
            print("Unable to load majors from cache")
        }
        
        if let tagImageData = fileData["Tag images"] as? [Int: UIImage] {
            self.tagImages = tagImageData
        }
        
        if let tagData = fileData["Tags"] as? [Int: String] {
            for cachedTag in tagData {
                tags[cachedTag.key] = Tag(id: cachedTag.key, name: cachedTag.value)
            }
        }
        
        if let keywordData = fileData["Keywords"] as? [String] {
            keywords = keywordData
        }
        
        updateMajors()
        updateKeywords()
    }
    
    /// Called when the app is about to terminate.
    static func saveToCache() {
        rawCache["Tag images"] = tagImages
        rawCache["Keywords"] = keywords
        rawCache["Majors"] = majors.mapValues { try! $0.encodedJSON.rawData() }
        if !NSKeyedArchiver.archiveRootObject(rawCache, toFile: CACHE_PATH) {
            print("Unable to save to location \(CACHE_PATH)")
        } else {
            // print("Successfully cached local storage to \(CACHE_PATH)")
        }
    }
    
}

extension LocalStorage {
    
    /** Load the tags from the server in the background.
     
     - Parameters:
        - handler: Called on completion or failure. `-1` indicates connection error, `-2` indicates server error, `0` indicates success.
     */
    
    static func updateTags(_ handler: ((Int) -> ())?) {
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/Tags",
                           parameters: ["withDefault": "1"])!
        
        var request = URLRequest(url: url)
        request.addAuthHeader()
                
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
                        
            guard error == nil else {
                DispatchQueue.main.async { handler?(-1) }
                return
            }
            
            if let json = try? JSON(data: data!).dictionary {
                if json?["status"]!.stringValue == INTERNAL_ERROR {
                    DispatchQueue.main.async { handler?(-2) }
                } else {
                    for (tagIndex, tagName) in json!["tagIDs"]?.dictionaryValue ?? [:] {
                        let tag = Tag(id: Int(tagIndex) ?? -1, name: tagName.stringValue)
                        self.tags[tag.id] = tag
                    }
                    rawCache["Tags"] = self.tags.mapValues { $0.name }
                    DispatchQueue.main.async { handler?(0) }
                }
            } else {
                DispatchQueue.main.async { handler?(-2) }
            }
        }
        
        task.resume()
    }
    
    /// Fetch the logo for a tag.
    static func getLogoForTag(_ tagID: Int, handler: ((UIImage?) -> ())?) {
        
        if tagImages.keys.contains(tagID) {
            handler?(tagImages[tagID])
            // Update the logo images secretly anyway
        }
        
        let requestTime = Date()
        concurrentRequests[tagID] = requestTime
                        

        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetTagImage",
                           parameters: ["tagId": String(tagID)])!
        var request = URLRequest(url: url)
        request.addAuthHeader()

        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            if let latest = concurrentRequests[tagID], latest > requestTime {
                return // Invalidate current request since it's not the lastest one
            } else {
                concurrentRequests.removeValue(forKey: tagID)
            }

            guard error == nil else {
                print("WARNING: Get tag image API returned error tag with ID \(tagID)!")
                DispatchQueue.main.async {
                    handler?(nil)
                }
                return // Don't display any alert here
            }
            if let newLogo = UIImage(data: data!) {
                LocalStorage.tagImages[tagID] = newLogo
                DispatchQueue.main.async {
                    handler?(newLogo)
                }
            } else {
                DispatchQueue.main.async {
                    handler?(nil)
                }
            }
            
        }

        task.resume()
    }
    
    /// Fetch major information from the server.
    static func updateMajors(_ handler: ((Int) -> ())? = nil) {
        
        let url = URL(string: API_BASE_URL + "Majors")!
        let task = CUSTOM_SESSION.dataTask(with: url) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async { handler?(-1) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    updateMajors(nil)
                }
                return
            }
            
            if let json = try? JSON(data: data!), let array = json.array {
                var allMajors = [Int: Major]()
                for m in array {
                    let major = Major(json: m)
                    allMajors[major.id] = major
                }
                if !allMajors.isEmpty {
                    majors = allMajors
                    print("\(allMajors.count) majors are loaded")
                    DispatchQueue.main.async { handler?(0) }
                } else {
                    print("WARNING: 0 majors were loaded from server")
                }
            } else {
                DispatchQueue.main.async { handler?(-2) }
            }
        }
        
        task.resume()
    }
    
    /// Fetches the latest event search keywords from the server.
    static func updateKeywords(_ handler: ((Int) -> ())? = nil) {
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/Keywords",
                           parameters: [:])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async { handler?(-1) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    updateKeywords()
                }
                return
            }
            
            if let json = try? JSON(data: data!), let kwArray = json.arrayObject as? [String] {
                keywords = kwArray
                print("\(kwArray) keywords are loaded from server")
                DispatchQueue.main.async { handler?(0) }
            } else {
                DispatchQueue.main.async { handler?(-2) }
            }
        }
        
        task.resume()
    }
    
}
