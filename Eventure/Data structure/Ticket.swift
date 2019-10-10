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
    var username: String?
    var userEmail: String?
    var eventID: String
    var eventName: String
    var hostName: String
    var hostID: String
    var paymentType: PaymentType = .none
    var transferable: Bool
    var transferLocked: Bool
    var transferHistory = [Int]()
    
    var paymentInfo: String {
        switch paymentType {
        case .offline:
            return "offline transaction"
        case .none:
            return "unknown payment"
        case .credit:
            return paymentDescription + " (card)"
        default:
            return paymentDescription + " (\(paymentType.rawValue))"
        }
    }
    var quantity: Int
    var ticketPrice: Double
    var paymentAmount: Double
    var paymentDescription: String {
        return String(format: "$%.02f", paymentAmount)
    }
    var redeemCode: String?
    var admissionID: String
    var typeName: String
    var eventDate: Date?
    var eventEndDate: Date?
    var transactionDate: Date?
    var activationDate: Date?
    var creationDate: Date?
    var location: String
    var notes: String
    
    let hasLogo: Bool
    var orgLogo: UIImage?
    var eventCover: UIImage?
    var associatedEvent: Event?
    
    required init(ticketInfo: JSON) {
        let dictionary = ticketInfo.dictionaryValue
        
        ticketID = dictionary["Ticket ID"]?.string ?? ""
        userID = dictionary["User ID"]?.int ?? -1
        userEmail = dictionary["Email"]?.string
        username = dictionary["Displayed name"]?.string
        if username == nil {
            username = userEmail
        }
        transferable = (dictionary["Transferable"]?.int ?? 0) == 1
        transferLocked = (dictionary["Transfer lock"]?.int ?? 1) == 1
        
        if let th = dictionary["Transfer history"]?.string {
            if let arr = JSON(parseJSON: th).arrayObject as? [Int] {
                transferHistory = arr
            }
        }
        
        redeemCode = dictionary["Code"]?.string
        eventID = dictionary["Event ID"]?.string ?? ""
        eventName = dictionary["Event title"]?.string ?? ""
        hostName = dictionary["Organization title"]?.string ?? ""
        hostID = dictionary["Organization"]?.string ?? ""
        hasLogo = (dictionary["Has logo"]?.int ?? 0) == 1
        admissionID = dictionary["Admission ID"]?.string ?? ""
        typeName = dictionary["Type name"]?.string ?? "<Ticket name>"
        quantity = dictionary["Quantity"]?.int ?? 1
        ticketPrice = dictionary["Ticket price"]?.double ?? 0.0
        paymentAmount = dictionary["Payment amount"]?.double ?? 0.0
        location = dictionary["Location"]?.string ?? "TBA"
        notes = dictionary["Notes"]?.string ?? ""
        
        if let eventDateString = dictionary["Start time"]?.string {
            eventDate = DATE_FORMATTER.date(from: eventDateString)
        }
        
        if let creationString = dictionary["Creation date"]?.string {
            creationDate = DATE_FORMATTER.date(from: creationString)
        }
        
        if let endString = dictionary["End time"]?.string {
            eventEndDate = DATE_FORMATTER.date(from: endString)
        }
        
        if let dateString = dictionary["Transaction date"]?.string {
            transactionDate = DATE_FORMATTER.date(from: dateString)
        }
        
        if let activationDateString = dictionary["Activation date"]?.string {
            activationDate = DATE_FORMATTER.date(from: activationDateString)
        }
        
        if let paymentRaw = dictionary["Payment type"]?.string {
            paymentType = PaymentType(rawValue: paymentRaw) ?? .none
        }
        
    }
    
    private var encodedJSON: JSON {
        var main = JSON()
        
        main.dictionaryObject?["Ticket ID"] = ticketID
        main.dictionaryObject?["Type name"] = typeName
        main.dictionaryObject?["Transferable"] = transferable ? 1 : 0
        main.dictionaryObject?["Transfer lock"] = transferLocked ? 1 : 0
        main.dictionaryObject?["Transfer history"] = transferHistory.description
        main.dictionaryObject?["Admission ID"] = admissionID
        main.dictionaryObject?["User ID"] = userID
        main.dictionaryObject?["Email"] = userEmail
        main.dictionaryObject?["Displayed name"] = username
        main.dictionaryObject?["Event ID"] = eventID
        main.dictionaryObject?["Event title"] = eventName
        main.dictionaryObject?["Organization title"] = hostName
        main.dictionaryObject?["Organization"] = hostID
        main.dictionaryObject?["Quantity"] = quantity
        main.dictionaryObject?["Payment amount"] = paymentAmount
        main.dictionaryObject?["Payment type"] = paymentType.rawValue
        main.dictionaryObject?["Has logo"] = hasLogo ? 1 : 0
        main.dictionaryObject?["Location"] = location
        main.dictionaryObject?["Notes"] = notes
        main.dictionaryObject?["Code"] = redeemCode
        
        if activationDate != nil {
            main.dictionaryObject?["Activation date"] = DATE_FORMATTER.string(from: activationDate!)
        }

        if creationDate != nil {
            main.dictionaryObject?["Creation date"] = DATE_FORMATTER.string(from: creationDate!)
        }
        
        if eventDate != nil {
            main.dictionaryObject?["Start time"] = DATE_FORMATTER.string(from: eventDate!)
        }
        
        if eventEndDate != nil {
            main.dictionaryObject?["End time"] = DATE_FORMATTER.string(from: eventEndDate!)
        }
        
        if transactionDate != nil {
            main.dictionaryObject?["Transaction date"] = DATE_FORMATTER.string(from: transactionDate!)
        }
        
        return main
    }
    
    func fetchEventImage(_ handler: ((Ticket) -> ())?) {
        if !hasLogo { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventCover",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.eventCover = UIImage(data: data!)
            DispatchQueue.main.async {
                handler?(self)
            }
        }
        
        task.resume()
    }
    
    func getEvent(handler: ((Bool) -> ())?) {
        
        guard associatedEvent == nil else {
            handler?(true)
            return
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            if let eventDictionary = try? JSON(data: data!) {
                let event = Event(eventInfo: eventDictionary)
                self.associatedEvent = event
                event.eventVisual = self.eventCover
                
                DispatchQueue.main.async {
                    handler?(true)
                }
                
            } else {
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    /// Load the logo image for the host organization.
    func getLogoImage(handler: ((Ticket) -> ())?) {
        if !hasLogo { return }
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetLogo",
                           parameters: ["id": hostID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                print("WARNING: Get logo image returned error for organization!")
                return // Don't display any alert here
            }
            
            if let newLogo = UIImage(data: data!) {
                self.orgLogo = newLogo
                DispatchQueue.main.async {
                    handler?(self)
                }
            }
        }
        
        task.resume()
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
    
    var QRCode: UIImage? {
        return generateQRCode(from: APP_DOMAIN + "ticket?id=" + ticketID)
    }
    
    var QRCodeDark: UIImage? {
        return generateQRCode(from: APP_DOMAIN + "ticket?id=" + ticketID, dark: true)
    }
    
    
    static func updateTickets() {
        
        guard User.current != nil else { return }
        
        var logoCache = [String : UIImage]()
        userTickets.forEach { logoCache[$0.ticketID] = $0.orgLogo }

        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetTickets",
                           parameters: ["userId": String(User.current!.userID)])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil && User.current != nil else {
                return
            }
            
            if let json = try? JSON(data: data!), let tickets = json.array {
                var tmp = Set<Ticket>()
                for ticketData in tickets {
                    let newTicket = Ticket(ticketInfo: ticketData)
                    if newTicket.userID == User.current!.userID {
                        newTicket.orgLogo = logoCache[newTicket.ticketID]
                        tmp.insert(newTicket)
                    }
                }
                
                userTickets = tmp
                
                NotificationCenter.default.post(name: USER_SYNC_SUCCESS, object: nil)

                DispatchQueue.global(qos: .default).async {
                    if let current = User.current {
                        Ticket.writeToFile(userID: current.uuid)
                    }
                }
            }
        }
        
        task.resume()
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
        case venmo = "Venmo"
        case credit = "Credit/debit card"
        case paypal = "Paypal"
        case none = "N/A"
        case issued = "Issued"
        case offline = "Offline"
    }
}
