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
    static var userTickets = [Ticket]()
    
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
        
        if transactionDate != nil {
            main.dictionaryObject?["Transaction date"] = DATE_FORMATTER.string(from: transactionDate!)
        }
        
        return main
    }
    
    func save() {
        Ticket.writeToFile(userID: userID)
    }
    
    static func writeToFile(userID: Int) -> Bool {
        
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
