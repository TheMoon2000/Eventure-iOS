//
//  CheckinNavigationController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = AppColors.main
        navigationBar.barTintColor = .white
    }

}

class PortraitNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = AppColors.main
        navigationBar.barTintColor = AppColors.navbar
        navigationBar.isTranslucent = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
