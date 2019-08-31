//
//  EventCheckinOverview.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinOverview: UIViewController {
    
    private var event: Event!
    
    required init(event: Event!) {
        super.init(nibName: nil, bundle: nil)
        
        self.event = event
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    

}
