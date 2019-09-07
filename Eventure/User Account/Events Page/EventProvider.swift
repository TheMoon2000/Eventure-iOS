//
//  EventProvider.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

protocol EventProvider: UIViewController {
    var eventsForSearch: [Event] { get }
}
