//
//  LocalCache.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2020/2/21.
//  Copyright © 2020 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A class designated for storing cached information.
class LocalStorage {
    
    static var CACHE_PATH = ACCOUNT_DIR.path + "/" + "LocalStorage"
    
    /// Internal representation of the local storage.
    static private var rawCache = [String: [Int: Any]]()
    
    /// Maps tag IDs to Tag objects.
    static var tags = [Int: Tag]()
    
    /// Maps major IDs to `Major` objects.
    static var majors = [Int: Major]()
    
    private init() {}
    
    static func recoverFromCache() {
        let fileData = (NSKeyedUnarchiver.unarchiveObject(withFile: CACHE_PATH) as? [String: [Int: Any]]) ?? [:]
                
        rawCache = fileData
        
        if let majorData = fileData["Majors"] {
            for cachedMajor in majorData {
                if let data = try? JSON(data: cachedMajor.value as! Data) {
                    majors[cachedMajor.key] = Major(json: data)
                }
            }
            print("Loaded \(majors.count) majors from local cache")
        } else {
            print("Unable to load majors from cache")
        }
        
        if let tagData = fileData["Tags"] as? [Int: String] {
            for cachedTag in tagData {
                tags[cachedTag.key] = Tag(id: cachedTag.key, name: cachedTag.value)
            }
        }
        
        updateMajors()
    }
    
    static func saveToCache() {
        if !NSKeyedArchiver.archiveRootObject(rawCache, toFile: CACHE_PATH) {
            print("Unable to save to location \(CACHE_PATH)")
        } else {
            print("Successfully cached local storage to \(CACHE_PATH)")
        }
    }
    
}

extension LocalStorage {
    
    /**
     
     Load the tags from the server in the background.
     
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
                    for (tagIndex, tagName) in json?["tagIDs"]?.dictionaryValue ?? [:] {
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
                    rawCache["Majors"] = allMajors.mapValues { try! $0.encodedJSON.rawData() }
                    saveToCache()
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
    
}
