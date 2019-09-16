//
//  Ticket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Ticket {
    
    static var allTickets = [Int: [[String : Any]]]()
    static var userTickets = Set<Ticket>()
    
    var ticketID: String
    var userID: Int
    var eventID: String
    var eventName: String
    var hostName: String
    var hostID: String
    var paymentType: PaymentType = .none
    var quantity: Double
    var eventDate: Date?
    var transactionDate: Date?
    
    let hasLogo: Bool
    var orgLogo: UIImage?
    
    required init(ticketInfo: JSON) {
        let dictionary = ticketInfo.dictionaryValue
        
        ticketID = dictionary["Ticket ID"]?.string ?? ""
        userID = dictionary["User ID"]?.int ?? -1
        eventID = dictionary["Event ID"]?.string ?? ""
        eventName = dictionary["Event title"]?.string ?? ""
        hostName = dictionary["Organization title"]?.string ?? ""
        hostID = dictionary["Organization"]?.string ?? ""
        hasLogo = (dictionary["Has logo"]?.int ?? 0) == 1
        quantity = dictionary["Quantity"]?.double ?? 0.0
        
        if let eventDateString = dictionary["Start time"]?.string {
            eventDate = DATE_FORMATTER.date(from: eventDateString)
        }
        
        if let dateString = dictionary["Transaction date"]?.string {
            transactionDate = DATE_FORMATTER.date(from: dateString)
        }
        
        if let paymentRaw = dictionary["Payment type"]?.string {
            paymentType = PaymentType(rawValue: paymentRaw) ?? .none
        }
        
    }
    
    private var encodedJSON: JSON {
        var main = JSON()
        
        main.dictionaryObject?["Ticket ID"] = ticketID
        main.dictionaryObject?["User ID"] = userID
        main.dictionaryObject?["Event ID"] = eventID
        main.dictionaryObject?["Event title"] = eventName
        main.dictionaryObject?["Organization title"] = hostName
        main.dictionaryObject?["Organization"] = hostID
        main.dictionaryObject?["Quantity"] = quantity
        main.dictionaryObject?["Payment type"] = paymentType.rawValue
        
        if eventDate != nil {
            main.dictionaryObject?["Start time"] = DATE_FORMATTER.string(from: eventDate!)
        }
        
        if transactionDate != nil {
            main.dictionaryObject?["Transaction date"] = DATE_FORMATTER.string(from: transactionDate!)
        }
        
        return main
    }
    
    func save() {
        Ticket.writeToFile(userID: userID)
    }
    
    @discardableResult static func writeToFile(userID: Int) -> Bool {
        
        var collection = [[String : Any]]()
        
        for ticket in userTickets {
            var ticketInfo = [String : Any]()
            
            let mainEncrypted: Data? = NSData(data: try! ticket.encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)
            
            ticketInfo["main"] = mainEncrypted
            ticketInfo["org logo"] = ticket.orgLogo
            
            collection.append(ticketInfo)
        }
        
        allTickets[userID] = collection
        
        if NSKeyedArchiver.archiveRootObject(allTickets, toFile: TICKETS_PATH) {
            return true
        } else {
            return false
        }
    }
    
    static func readFromFile() -> [Int: Set<Ticket>] {
        
        var tickets = [Int: Set<Ticket>]()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: TICKETS_PATH) else {
            return [:] // It's fine if no event collection cache exists.
        }
        
        guard let collection = fileData as? [Int: [[String : Any]]] else {
            print("WARNING: Cannot read tickets at \(TICKETS_PATH)!")
            return [:]
        }
        
        allTickets = collection
        
        for (id, ticketsList) in collection {
            for ticketInfo in ticketsList {
                guard let mainData = ticketInfo["main"] as? Data else {
                    print("WARNING: Key `main` not found for user ID \(id) in ticket cache!")
                    continue
                }
                
                guard let decryptedMain: Data = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
                    print("WARNING: Unable to decrypt tickets for user \(id)!")
                    continue
                }
                
                if let json = try? JSON(data: decryptedMain) {
                    let ticket: Ticket = Ticket(ticketInfo: json)
                    var userSpecificTickets: Set<Ticket> = tickets[id] ?? []
                    
                    ticket.orgLogo = ticketInfo["org logo"] as? UIImage
                    userSpecificTickets.insert(ticket)
                    
                    tickets[id] = userSpecificTickets
                } else {
                    print("WARNING: Unable to parse decrypted ticket main data as JSON!")
                }
            }
        }
        
        return tickets
    }
}


extension Ticket: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ticketID)
    }
    
    static func ==(lhs: Ticket, rhs: Ticket) -> Bool {
        return lhs.ticketID == rhs.ticketID
    }
}


extension Ticket {
    enum PaymentType: String {
        case offline = "Offline"
        case venmo = "Venmo"
        case credit = "Credit/debit card"
        case paypal = "Paypal"
        case none = "N/A"
    }
}
