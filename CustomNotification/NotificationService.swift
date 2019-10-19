//
//  NotificationService.swift
//  CustomNotification
//
//  Created by Jia Rui Shan on 2019/10/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UserNotifications

/// Use this formatter to convert strings from API calls into dates and vice versa.
let DATE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "UTC")!
    return formatter
}()

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any], let startTime = aps["startTime"] as? String {
                let formatted = reformat(dateString: startTime)
                bestAttemptContent.body = bestAttemptContent.body.replacingOccurrences(of: startTime, with: formatted)
            }
            
            
            contentHandler(bestAttemptContent)
        }
    }
    
    private func reformat(dateString: String) -> String {
        
        guard let startTime = DATE_FORMATTER.date(from: dateString) else {
            return dateString
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        
        if Date().midnight == startTime.midnight {
            formatter.dateFormat = "h:mm a"
            return "today " + formatter.string(from: startTime)
        } else {
            formatter.dateFormat = "MMM. d, y 'at' h:mm a"
            return formatter.string(from: startTime)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}


extension Date {
    
    /// Truncates the hour, minute and second components of the date.
    var midnight: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: formatter.string(from: self))!
    }
}
