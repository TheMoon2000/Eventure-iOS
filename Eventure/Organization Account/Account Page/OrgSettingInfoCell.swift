//
//  OrgSettingInfoCell.swift
//  Eventure
//
//  Created by Prince Wang on 2019/9/1.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class OrgSettingInfoCell: UITableViewCell {
    
    var functionImage: UIImageView! //optional but you know it will be used
    var function: UILabel!
    var sideLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //add arrow to each cell
        accessoryType = .disclosureIndicator
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        functionImage = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            addSubview(image)
            
            //constraints for the images
            image.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            image.widthAnchor.constraint(equalToConstant: 32).isActive = true
            image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
            image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return image
        }()
        
        function = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 2
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: functionImage.rightAnchor, constant: 20).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        sideLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17)
            label.numberOfLines = 3
            label.textColor = UIColor.gray
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .right
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo:function.rightAnchor, constant: 100).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor,constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
            
            return label
        } ()
 
    }
    
    func setup(sectionNum: Int, rowNum: Int, type: String) {
        switch (sectionNum, rowNum) {
        case (0, 0):
            functionImage.image = #imageLiteral(resourceName: "windmill")
            sideLabel.text = Organization.current?.title
            function.text = "Organization Title"
        case (0, 1):
            functionImage.image = #imageLiteral(resourceName: "mac")
            function.text = "Password"
            sideLabel.text = "•••••••"
        case (0, 2):
            functionImage.image = #imageLiteral(resourceName: "comments")
            function.text = "Contact Email"
        default:
            print(IndexPath())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
