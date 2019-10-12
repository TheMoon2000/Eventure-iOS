//
//  Major.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import SwiftyJSON

class Major: Hashable {
    
    /// Maps a major ID to a `Major` object.
    static var currentMajors = [Int: Major]()
    
    var id: Int
    var fullName: String
    var abbreviation: String?
    
    required init(json: JSON) {
        let dictionary = json.dictionaryValue
        id = dictionary["id"]?.int ?? -1
        fullName = dictionary["Full name"]?.string ?? "Unknown"
        abbreviation = dictionary["Abbreviation"]?.string
    }
    
    static func ==(lhs: Major, rhs: Major) -> Bool {
        return lhs.fullName.lowercased() == rhs.fullName.lowercased()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fullName.lowercased())
    }
    
    private var encodedJSON: JSON {
        var json = JSON()
        json.dictionaryObject?["id"] = id
        json.dictionaryObject?["Full name"] = fullName
        json.dictionaryObject?["Abbreviation"] = abbreviation
        
        return json
    }
    
    static func recoverCache() {
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: MAJORS_PATH) else {
            return
        }
        
        guard let cache = fileData as? [Int : Data] else {
            print("WARNING: Cannot read cache as [String : Data]!")
            return
        }
        
        for cachedMajor in cache {
            if let data = try? JSON(data: cachedMajor.value) {
                currentMajors[cachedMajor.key] = Major(json: data)
            }
        }
    }
    
    static func save() {
        let data = currentMajors.mapValues { try! $0.encodedJSON.rawData() }
        NSKeyedArchiver.archiveRootObject(data, toFile: MAJORS_PATH)
    }
    
    static func updateCurrentMajors(_ handler: (() -> ())?) {
        
        let url = URL(string: API_BASE_URL + "Majors")!
        let task = CUSTOM_SESSION.dataTask(with: url) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    updateCurrentMajors(handler)
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
                    Major.currentMajors = allMajors
                    Major.save()
                    print("\(allMajors.count) majors are loaded")
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    updateCurrentMajors(handler)
                }
            }
        }
        
        task.resume()
    }
}
