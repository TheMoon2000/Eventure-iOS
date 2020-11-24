//
//  Global Constants.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This file documents all global constants and configurations used by the app.

import UIKit
import SwiftyJSON
import BonMot
import Down
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

// MARK: - Global constants

/// The URL prefix for all the APIs.
let API_BASE_URL = "https://api.eventure-app.com/"

/// APIs related to mails (among others) are hosted in a seperate API cluster due to compatibility reasons with SendGrid's library.
let PHP7_API_BASE_URL = "https://php7.api.eventure-app.com/"

/// Credentials: DO NOT include when committing
let USERNAME = "Eventure 1.2.1"
let PASSWORD = "af9140470b0d340e6832b79e0c78754100cf"

let AES_KEY = "aes key"
let INTERNAL_ERROR = "internal error"
let UNAUTHORIZED_ERROR = "unauthorized"
let CONNECTION_ERROR = "Connection error"
let SERVER_ERROR = "Server error"
let APP_STORE_LINK = "https://apps.apple.com/app/id1478542362"
let APP_DOMAIN = "https://eventure-app.com/"

let KEY_ACCOUNT_TYPE = "Account Type"
let ACCOUNT_TYPE_USER = "User"
let ACCOUNT_TYPE_ORG = "Org"

let URL_PREFIX = "eventure://"

/// Notification types
enum NotificationKeys: String {
    case oneTimeCode = "one-time code"
    case generalNotice = "general notice"
    case ticketActivation = "ticket activation"
    case ticketRedemption = "ticket redemption"
    case ticketRequest = "ticket request"
    case ticketRequestApproved = "ticket request approved"
    case ticketTransferRequest = "ticket transfer request"
    case ticketTransferApproved = "ticket transfer approved"
    case ticketTransferDeclined = "ticket transfer declined"
    case eventTimeUpdate = "event time update"
    case eventLocationUpdate = "event location update"
    case newEvent = "new event"
    case messageUpdate = "message update"
}

/// Legacy main disabled color.
let MAIN_DISABLED = UIColor(red: 1.0, green: 168/255, blue: 150/255, alpha: 0.6)
let LIGHT_RED = UIColor(red: 1, green: 100/255, blue: 90/255, alpha: 1)

let MAIN_TINT6 = UIColor(red: 236/255, green: 110/255, blue: 173/255, alpha: 1.0)
let MAIN_TINT8 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)

/// A suite of custom colors used by the app, adjusted for both light and dark mode.
struct AppColors {
    /// The primary theme color of the app.
    static var main = UIColor(named: "AppColors.main")!
    
    /// The disabled theme color.
    static var mainDisabled = UIColor(named: "AppColors.mainDisabled")!
    
    /// A lighter version of the main tint.
    static var mainLight = UIColor(named: "AppColors.mainLight")!
    
    /// The darker theme color.
    static var mainDark = UIColor(named: "AppColors.mainDark")!
    
    /// A red color used for fatal errors.
    static var fatal = UIColor(red: 230/255, green: 33/255, blue: 15/255, alpha: 1)
    
    /// A orange-yellow color used for warnings.
    static var warning = UIColor(red: 243/255, green: 213/255, blue: 34/255, alpha: 1)
    
    /// A light green color to indicate a passed state.
    static var passed = UIColor(named: "AppColors.passed")!
    
    /// The color that indicates a registrant pending check-in.
    static var pending = UIColor(named: "AppColors.pending")!
    
    /// The yellow color for the interest button.
    static var interest = UIColor(red: 254/255, green: 206/255, blue: 56/255, alpha: 1)
    
    /// The color used for hyperlinks.
    static var link = UIColor(named: "AppColors.link")!
    
    /// The color used for active hyperlinks.
    static var linkPressed = UIColor(named: "AppColors.link_pressed")!
    
    /// Placeholder text color.
    static var placeholder = UIColor(named: "AppColors.placeholder")!
    
    /// A light gray color used for border lines.
    static var line = UIColor(named: "AppColors.line")!
    
    /// A lighter line color suitable for white backgrounds.
    static var lineLight = UIColor(named: "AppColors.lineLight")!
    
    /// A dark gray color intended for title labels.
    static var label = UIColor(named: "AppColors.label")!
    
    /// A dark gray color (1/4 darkness) intended to display values.
    static var value = UIColor(named: "AppColors.value")!
    
    /// A medium gray color intended for secondary / supplementary text labels.
    static var prompt = UIColor(named: "AppColors.prompt")!
    
    /// The background color that should be used for most view controllers.
    static var background = UIColor(named: "AppColors.background")!
    
    /// The background color for subviews.
    static var subview = UIColor(named: "AppColors.subview")!
    
    /// The background color for a selected subview.
    static var selected = UIColor(named: "AppColors.selected")!
    
    /// The background color for event previews.
    static var card = UIColor(named: "AppColors.card")!
    
    /// The background color for navigation bars.
    static var navbar = UIColor(named: "AppColors.navbar")!
    
    /// A darker navigation bar background color.
    static var darkerNavBar = UIColor(named: "AppColors.darkerNavBar")!
    
    /// Dark background for scrollviews. In light mode, this is a very light gray.
    static var canvas = UIColor(named: "AppColors.canvas")!
    
    /// Background color for tab strips.
    static var tab = UIColor(named: "AppColors.tab")!
    
    /// Background color for grouped table views.
    static var tableBG = UIColor(named: "AppColors.tableBG")!
    
    /// Plain text color, intended for event and organization descriptions.
    static var plainText = UIColor(named: "AppColors.plainText")!

    /// Bold text color.
    static var boldText = UIColor(named: "AppColors.bold")!
    
    /// Button colors.
    static var control = UIColor(named: "AppColors.control")!
    
    /// A light gray tint used for disabled controls.
    static var disabled = UIColor(named: "AppColors.disabled")!
    
    /// Message header background color.
    static var messageHeader = UIColor(named: "AppColors.messageHeader")!
    
    /// The label color for a dark background.
    static var invertedLabel = UIColor(named: "AppColors.invertedLabel")!
    
    /// Badge color for messages.
    static var badgeColor = UIColor(named: "AppColors.badge")!
    
    /// Emphasis color for values within messages.
    static var emphasis = UIColor(named: "AppColors.emphasis")!
    
    /// A lighter control color used for spinners and other UI elements.
    static var lightControl = UIColor(named: "AppColors.lightControl")!
    
    /// A light gray tint color.
    static var lightGray = UIColor(named: "AppColors.views")!
    
    /// Application start time color.
    static var startTime = UIColor(named: "AppColors.start")!
    
    /// Background color for category cell images.
    static var categoryBG = UIColor(named: "AppColors.categoryBG")!
    
    /// Keyword text color for event searching.
    static var keyword = UIColor(named: "AppColors.keyword")!
    
    /// Announcement box color for dining menus.
    static var announcement = UIColor(named: "AppColors.announcement")!
    
    /// Darker color accompanying an announcement.
    static var announcementDark = UIColor(named: "AppColors.announcementDark")
    
    /// Used for reload button colors.
    static var lightTitle = UIColor(named: "AppColors.lightTitle")!
}

let SAMPLE_TEXT = """
[This is a Markdown Link](https://www.google.com).

**Lorem ipsum dolor sit amet**, ligula suspendisse nulla pretium, rhoncus tempor fermentum, enim integer ad vestibulum volutpat. Nisl rhoncus turpis est, vel elit, congue wisi enim nunc ultricies sit, magna tincidunt. Maecenas aliquam maecenas ligula nostra, accumsan taciti. Sociis mauris in integer, a dolor netus non dui aliquet, sagittis felis sodales, dolor sociis mauris, vel eu libero cras. Faucibus at. Arcu habitasse elementum est, ipsum purus pede porttitor class, ut adipiscing, aliquet sed auctor, imperdiet arcu per diam dapibus libero duis. Enim eros in vel, volutpat nec pellentesque leo, temporibus scelerisque nec.
### Second paragraph with heading
Ac dolor ac adipiscing amet bibendum nullam, lacus molestie ut libero nec, diam et, pharetra sodales, feugiat ullamcorper id tempor id vitae. Mauris pretium aliquet, lectus tincidunt. Porttitor mollis imperdiet libero senectus pulvinar. Etiam molestie mauris ligula laoreet, vehicula eleifend. Repellat orci erat et, sem cum, ultricies sollicitudin amet eleifend dolor nullam erat, malesuada est leo ac. Varius natoque turpis elementum est. Duis montes, tellus lobortis lacus amet arcu et. In vitae vel, wisi at, id praesent bibendum libero faucibus porta egestas, quisque praesent ipsum fermentum tempor. Curabitur auctor, erat mollis sed, turpis vivamus a dictumst congue magnis. Aliquam amet ullamcorper dignissim molestie, mollis. Tortor vitae tortor eros wisi facilisis.
"""

let PLAIN_STYLE =  """
    body {
        font-family: "Proxima Nova";
        font-size: 17px;
        line-height: 1.5;
        letter-spacing: 1.5%;
        color: #525252;
        margin-bottom: 12px;
    }

    li {
        margin-bottom: 8px;
    }

    strong, em {
        color: #4A4A4A;
    }

    a {
        text-decoration: none;
    }


    h1, h2, h3, h4, h5, h6 {
        font-family: "Proxima Nova";
        font-weight: 600;
        letter-spacing: 1.5%;
        color: rgb(255, 120, 104);
        line-height: 1.4;
    }

    h1 {
        font-size: 23px;
        margin-bottom: 14px;
    }

    h2 {
        font-size: 22px;
        margin-bottom: 13.5px;
    }

    h3 {
        font-size: 21px;
        margin-bottom: 13px;
    }

    h4 {
        font-size: 20px;
        margin-bottom: 12.5px;
    }

    h5 {
        font-size: 19px;
        margin-bottom: 12px;
    }
    h6 {
        margin-bottom: 11px;
        font-size: 18px;
    }

    a {
        color: rgb(104, 165, 245);
    }
"""

let PLAIN_DARK = PLAIN_STYLE.replacingOccurrences(of: "#525252", with: "#C9C9C9").replacingOccurrences(of: "#4A4A4A", with: "#D7D7D7")

let COMPACT_STYLE = """
    body {
        font-family: "Proxima Nova";
        font-size: 16px;
        line-height: 1.25;
        letter-spacing: 1%;
        color: #6A6A6A;
        margin-bottom: 10px;
    }

    strong, em {
        color: #505050;
    }
"""

let COMPACT_DARK = COMPACT_STYLE.replacingOccurrences(of: "#505050", with: "#D3D3D3").replacingOccurrences(of: "#6A6A6A", with: "#C0C0C0")

let TITLE_STYLE = """
    body {
        font-family: "Proxima Nova";
        font-weight: 600;
        font-size: 18px;
        line-height: 1.4;
        letter-spacing: 1%;
        color: #505050;
        margin-bottom: 10px;
    }

    strong, em {
        color: #303030;
    }
"""

// MARK: - Cache files

let DRAFTS_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("drafts")
let ACCOUNT_DIR = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Account", isDirectory: true)

let CURRENT_USER_PATH = ACCOUNT_DIR.path + "/" + "user"
let TICKETS_PATH = ACCOUNT_DIR.path + "/" + "tickets"
let NOTIFICATIONS_PATH = ACCOUNT_DIR.path + "/" + "notifications"
let LOGO_CACHE = ACCOUNT_DIR.path + "/" + "logos"

/// Height between items in a vertical stack
let VERTICAL_SPACING: CGFloat = 13

/// Alpha value for disabled UI elements.
let DISABLED_ALPHA: CGFloat = 0.5

/// Custom URLSessionConfiguration with no caching
let CUSTOM_SESSION: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 60.0
    return URLSession(configuration: config)
}()

/// Use this formatter to convert strings from API calls into dates and vice versa.
let DATE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "UTC")!
    return formatter
}()

/// Same as `DATE_FORMATTER` except with milliseconds.
let PRECISE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    formatter.timeZone = TimeZone(abbreviation: "UTC")!
    return formatter
}()

/// A formatter to get the current year in string format.
let YEAR_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

/// A formatter to get the current month in string format.
let MONTH_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

let WEEK_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

/// A formatter to get the current month in string format.
let DAY_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()


// MARK: - Classes and Extensions

extension StringStyle {
    static let valueStyle = StringStyle(
        .font(UIFont.appFontMedium(15.5)),
        .lineHeightMultiple(1.1),
        .color(AppColors.emphasis)
    )
    
    static let valueLarge = StringStyle(
        .font(UIFont.appFontMedium(18)),
        .lineHeightMultiple(1.2),
        .color(AppColors.value)
    )
    
    static let basicStyle = StringStyle(
        .font(UIFont.appFontRegular(15.5)),
        .lineHeightMultiple(1.1),
        .color(AppColors.plainText)
    )
    
    static let basicLarge = StringStyle(
        .font(UIFont.appFontRegular(18)),
        .lineHeightMultiple(1.2),
        .color(AppColors.value)
    )
}

// Standardized app font
extension UIFont {
    static func appFontLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Light", size: size)!
    }
    static func appFontRegular(_ size: CGFloat) -> UIFont{
        return UIFont(name: "ProximaNova-Regular", size: size)!
    }
    
    static func appFontMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Medium", size: size)!
    }
    
    static func appFontSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Semibold", size: size)!
    }
    
    static func appFontBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Bold", size: size)!
    }
}

extension String {
    
    /// URL encoded string.
    var encoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? self
    }
    
    /// URL decoded string.
    var decoded: String {
        return self.removingPercentEncoding ?? self
    }
    
    /// Email verification method.
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Markdown-formatted text.
    func attributedText(style: String = PLAIN_STYLE) -> NSAttributedString {
        if isEmpty { return NSAttributedString() }
        if let d = try? Down(markdownString: self).toAttributedString(.default, stylesheet: style) {
            if d.string.isEmpty {
                return NSAttributedString(string: self, attributes: EventDetailPage.standardAttributes)
            }
            return d.attributedSubstring(from: NSMakeRange(0, d.length - 1))
        } else {
            print("WARNING: markdown failed")
            return NSAttributedString(string: self, attributes: EventDetailPage.standardAttributes)
        }
    }
    
    func md5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

}

extension Date {
    
    static let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static let todayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Today' @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static let sameYearFull: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static let differentYearFull: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM. d, h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    /// Truncates the hour, minute and second components of the date.
    var midnight: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: formatter.string(from: self))!
    }
    
    func readableString() -> String {
        if YEAR_FORMATTER.string(from: Date()) != YEAR_FORMATTER.string(from: self) {
            return Date.readableFormatter.string(from: self)
        } else if DAY_FORMATTER.string(from: Date()) != DAY_FORMATTER.string(from: self) {
            return Date.shortFormatter.string(from: self)
        } else {
            return Date.todayFormatter.string(from: self)
        }
    }
    
    func inlineString() -> String {
        if YEAR_FORMATTER.string(from: Date()) != YEAR_FORMATTER.string(from: self) {
            return "on " + Date.readableFormatter.string(from: self)
        } else if DAY_FORMATTER.string(from: Date()) != DAY_FORMATTER.string(from: self) {
            return "on " + Date.shortFormatter.string(from: self)
        } else {
            return "at " + Date.timeFormatter.string(from: self)
        }
    }
    
    
    var fullString: String {
        if YEAR_FORMATTER.string(from: Date()) != YEAR_FORMATTER.string(from: self) {
            return Date.differentYearFull.string(from: self)
        } else {
            return Date.sameYearFull.string(from: self)
        }
    }
    
    var shortString: String {
        let today = Date().midnight
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        
        if today == self.midnight {
            df.dateFormat = "h:mm a"
        } else if today.timeIntervalSince(self.midnight) == 86400 {
            df.dateFormat = "'Yesterday'"
        } else if today.timeIntervalSince(self.midnight) <= 7 * 86400 {
            df.dateFormat = "EEEE"
        } else {
            df.dateFormat = "MM/dd/yyyy"
        }
        
        return df.string(from: self)
    }
    
    var mediumString: String {
        let today = Date().midnight
        
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        
        if today == self.midnight {
            df.dateFormat = "h:mm a"
        } else if today.timeIntervalSince(self.midnight) == 86400 {
            df.dateFormat = "'Yesterday' h:mm a"
        } else if today.timeIntervalSince(self.midnight) <= 7 * 86400 {
            df.dateFormat = "EEEE, h:mm a"
        } else if YEAR_FORMATTER.string(from: self) == YEAR_FORMATTER.string(from: Date()) {
            df.dateFormat = "MMMM d"
        } else {
            df.dateFormat = "MMM d, yyyy"
        }
        
        return df.string(from: self)
    }
    
    var elapsedTimeDescription: String {
        let todayMidnight = Date().midnight
        let secondsPassed = Date().timeIntervalSince(self)
        if secondsPassed < 60 {
            let pluralSuffix = Int(secondsPassed) != 1 ? "s" : ""
            return "\(Int(secondsPassed)) second\(pluralSuffix) ago"
        } else if secondsPassed < 3600 {
            let minutes = Int(secondsPassed / 60)
            let pluralSuffix = minutes != 1 ? "s" : ""
            return "\(minutes) minute\(pluralSuffix) ago"
        } else if todayMidnight == midnight {
            let hours = Int(secondsPassed / 3600)
            let pluralSuffix = hours != 1 ? "s" : ""
            return "\(hours) hour\(pluralSuffix) ago"
        } else {
            return mediumString
        }
    }
    
    /// Returns the current hour of day (24-hour format).
    static var currentHour: Int {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "H"
        
        return Int(df.string(from: Date())) ?? -1
    }
}

extension URL {
    
    /**
     Custom URL formatter.
     
     - Parameters:
        - base: The base / parent URL of the API.
        - API_Name: The API name.
        - parameters: The url parameters in the form of a Swift native dictionary.
     
     - Returns: An optional URL object (URL?) formed from the provided information.
     */
    
    static func with(base: String, API_Name: String, parameters: [String: String]) -> URL? {
        if (parameters.isEmpty) {
            return URL(string: base + API_Name)
        }
        let formattedParameters = parameters.map {
            return $0.key.encoded + "=" + $0.value.encoded
        }
        return URL(string: "\(base + API_Name)?" + formattedParameters.joined(separator: "&"))
    }
}

extension URLRequest {
    
    /// Add a basic authorization header for the current request.
    mutating func addAuthHeader() {
        let token = "\(USERNAME):\(PASSWORD)".data(using: .utf8)!.base64EncodedString()
        self.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    }
    
    /// Add multipart data to the request.
    mutating func addMultipartBody(parameters: [String : String], files: [String: Data] = [:]) {
        
        // Build the body data
        
        let boundary = "----Eventure-API-Multipart-Boundary"
        let prefix = "--" + boundary + "\r\n"
        
        var data = Data()
        
        for parameter in parameters {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(parameter.key)\"\r\n\r\n")
            data.append(string: parameter.value + "\r\n")
        }
        
        for file in files {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(file.key)\"; filename=\"temp\"\r\n")
            data.append(string: "Content-Type: application/octet-stream\r\n\r\n")
            data.append(file.value)
            data.append(string: "\r\n")
        }
        
        data.append(string: "--" + boundary + "--")
        
        // Begin mutating the request
        self.addValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        self.httpBody = data
    }
}

class TopAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)?
            .map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        
        attributes?
            .reduce([CGFloat: (CGFloat, [UICollectionViewLayoutAttributes])]()) {
                guard $1.representedElementCategory == .cell else { return $0 }
                return $0.merging([ceil($1.center.y): ($1.frame.origin.y, [$1])]) {
                    ($0.0 < $1.0 ? $0.0 : $1.0, $0.1 + $1.1)
                }
            }
            .values.forEach { minY, line in
                line.forEach {
                    $0.frame = $0.frame.offsetBy(
                        dx: 0,
                        dy: minY - $0.frame.origin.y
                    )
                }
        }
        
        return attributes
    }
}

extension UIView {
    
    /// Extension method that finds the optimal height for the view, given its current width.
    func preferredHeight(width: CGFloat) -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.priority = .init(999)
        self.addConstraint(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.removeConstraint(widthConstraint)
        return height
    }
    
    /// Insert a standardized loading view into the target view. The loading view is hidden by default.
    func addLoader(withConstraints: Bool = true) -> UIVisualEffectView {
        
        let loadingBG: UIVisualEffectView = {
            var effect = UIBlurEffect(style: .extraLight)
            if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
                effect = UIBlurEffect(style: .regular)
            }
            let v = UIVisualEffectView(effect: effect)
            v.layer.cornerRadius = 12
            v.isHidden = true
            v.layer.masksToBounds = true
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.widthAnchor.constraint(equalToConstant: 110).isActive = true
            v.heightAnchor.constraint(equalTo: v.widthAnchor).isActive = true
            
            if withConstraints {
                v.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
                v.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            }
            
            return v
        }()
        
        let spinner: UIActivityIndicatorView = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .gray
            spinner.startAnimating()
            spinner.translatesAutoresizingMaskIntoConstraints = false
            loadingBG.contentView.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: loadingBG.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: loadingBG.centerYAnchor, constant: -10).isActive = true
            
            return spinner
        }()
        
        let _: UILabel = {
            let label = UILabel()
            label.text = "Loading..."
            label.textAlignment = .center
            label.font = .appFontRegular(15)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            loadingBG.contentView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 8).isActive = true
            
            return label
        }()
        
        return loadingBG
    }
    
    func addConnectionNotice(_ refresh: @escaping (() -> ())) -> (view: UIView, updater: ((UITraitCollection) -> ())) {
        
        let container: UIView = {
            let view = UIView()
            view.isHidden = true
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            view.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            
            return view
        }()
        
        let imageView: UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "offline_bear"))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 180).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 160).isActive = true
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            iv.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor).isActive = true
            iv.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor).isActive = true
            
            return iv
        }()
        
        let label: UILabel = {
            let label = UILabel()
            label.text = "Your inner bear has fallen."
            label.textColor = AppColors.lightTitle
            label.font = .appFontRegular(16)
            label.numberOfLines = 5
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            
            label.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        let button: UIButton = {
            let button = ClosureButton(type: .system)
            button.setTitle("Get Back Online", for: .normal)
            button.tintColor = AppColors.prompt
            button.titleLabel?.font = .appFontMedium(16)
            button.setTitleColor(AppColors.lightTitle, for: .normal)
            button.contentEdgeInsets.left = 22
            button.contentEdgeInsets.right = 22
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 6
            button.layer.borderColor = AppColors.line.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(button)
            
            
            button.leftAnchor.constraint(greaterThanOrEqualTo: container.leftAnchor).isActive = true
            button.rightAnchor.constraint(lessThanOrEqualTo: container.rightAnchor).isActive = true
            button.topAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 15).isActive = true
            button.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -10).isActive = true
            button.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
                
            button.action = {
                refresh()
                container.isHidden = true
            }
            
            return button
        }()
        
        return (container, { traits in
            if #available(iOS 13.0, *) {
                traits.performAsCurrent {
                    button.layer.borderColor = AppColors.line.cgColor
                }
            }
            
        })
    }
    
    func addCenteredLabel() -> UILabel {
        return {
            let label = UILabel()
            label.textColor = .gray
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .appFontRegular(17)
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
    }
    
    func applyMildShadow() {
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset.height = 0.5
    }
}

func generateQRCode(from string: String, dark: Bool = false) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        print("WARNING: Unable to find QR Generator filter")
        return nil
    }
    
    filter.setValue(data, forKey: "inputMessage")
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    
    guard var output = filter.outputImage?.transformed(by: transform) else {
        return nil
    }
    
    if dark {
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        colorInvertFilter.setValue(output, forKey: "inputImage")
        guard let inverted = colorInvertFilter.outputImage else { return nil }
        output = inverted
        
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(output, forKey: "inputImage")
        guard let masked = maskToAlphaFilter.outputImage else { return nil }
        output = masked
    }
    
    let context = CIContext()
    guard let cg = context.createCGImage(output, from: output.extent) else {
        return UIImage(ciImage: output)
    }
    
    return UIImage(cgImage: cg)
}


extension UITextField {
    func doInset() {
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = inset
        self.leftViewMode = .always
    }
}

extension UITextView {
    func doInset() {
        self.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    func preferredHeight() -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: frame.width)
        widthConstraint.priority = .init(999)
        self.addConstraint(widthConstraint)
        return contentSize.height
    }
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: .utf8)!
        append(data)
    }
}

extension UIImage {
    
    static let empty = UIImage()
    
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        case .up, .upMirrored:
            break
        }
        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        default:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    func sizeDownData(maxWidth: CGFloat = 400.0) -> Data {
        
        var imageToResize = self
        let originalSize = imageToResize.pngData()?.count
        
        if size.width > maxWidth {
            let newSize = CGSize(width: maxWidth, height: maxWidth / size.width * size.height)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            imageToResize = renderer.image { context in
                self.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        
        var currentQuality: CGFloat = 1.0
        var currentData = imageToResize.jpegData(compressionQuality: 1.0)
        
        while (currentData?.count ?? 0) > 500000 && currentQuality > 0.05 {
            currentQuality *= 0.8
            currentData = imageToResize.jpegData(compressionQuality: currentQuality)
        }
        
        print("Image reduced from \(String(describing: originalSize)) to \(String(describing: currentData?.count))")
        
        return currentData!
    }
    
    func sizeDown(maxWidth: CGFloat = 400.0) -> UIImage {
        return UIImage(data: sizeDownData(maxWidth: maxWidth), scale: 0.8)!
    }
}

extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visibleViewController
    }
}

extension UIViewController {
    /// The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}

extension UINavigationBar {
    
    func customize() {
        barTintColor = AppColors.navbar
        tintColor = AppColors.main
        isTranslucent = false
        titleTextAttributes = [.font: UIFont.appFontSemibold(17)]
    }
    
}

extension UILabel {

    func addImageWith(name: String, behindText: Bool) {

        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)

        guard let txt = self.text else {
            return
        }

        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}

class GenericNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = AppColors.navbar
        navigationBar.tintColor = AppColors.main
        navigationBar.isTranslucent = false
    }
    
}

class ClosureButton: UIButton {
    var action: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    @objc private func touchUpInside() {
        action?()
    }
}

/// Documents directory URL.
let DOCUMENTS_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

/// Cache directory URL.
let CACHES = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]


// MARK: - Standard alerts

func serverMaintenanceError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: "Unexpected error", message: "Oops, looks like the feature you tried to access is unavailable or is currently under maintenance. We're very sorry for the inconvenience and we hope that you will come back later.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    
    vc.present(alert, animated: true, completion: nil)
}

func genericError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: "Unexpected error", message: "An error has occurred.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    
    vc.present(alert, animated: true, completion: nil)
}

func internetUnavailableError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    alert.title = "Unable to Connect"
    alert.message = "Please check your internet connection."
    alert.addAction(.init(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    vc.present(alert, animated: true, completion: nil)
}

func authorizationError(handler: (() -> ())? = nil) {
    let noticeScreen = UpdateNotice()
    noticeScreen.modalPresentationStyle = .fullScreen
    UIApplication.topMostViewController?.present(noticeScreen, animated: true)
}

// MARK: - Notifications
let USER_SYNC_SUCCESS = Notification.Name("user sync success")
let USER_SYNC_FAILED = Notification.Name("user sync failed")
let ORG_SYNC_SUCCESS = Notification.Name("org sync success")
let ORG_SYNC_FAILED = Notification.Name("org sync failed")
let TICKET_ACTIVATED = Notification.Name("ticket activated")
let NEW_TICKET_REQUEST = Notification.Name("new ticket request")
let TICKET_TRANSFER_STATUS = Notification.Name(rawValue: "ticket transfer status")
let NEW_NOTIFICATION = Notification.Name(rawValue: "notification")
let ORG_NEEDS_UPLOAD = Notification.Name("org needs upload")

// Network status
class NetworkStatus {
    
    private static var numberOfActivities = 0 {
        didSet {
            if numberOfActivities < 0 {
                numberOfActivities = 0
            }
        }
    }
    
    private init() {}
    
    /// Enqueue a network task, and show the network indicator.
    static func addTask() {
        DispatchQueue.main.async {
            NetworkStatus.numberOfActivities += 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    /// Dequeue a network task. If there are no more tasks, then hide the network indicator.
    static func removeTask() {
        DispatchQueue.main.async {
            NetworkStatus.numberOfActivities -= 1
            if NetworkStatus.numberOfActivities == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
}
