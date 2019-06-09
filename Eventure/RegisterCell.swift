//
//  RegisterCell.swift
//  Eventure
//
//  Created by Xiang Li on 6/4/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import DLRadioButton

class RegisterCell: UITableViewCell {
    var info : UITextField = UITextField()
    var blank : regLabel = regLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        blank.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blank)
        self.addSubview(info)
        blank.widthAnchor.constraint(equalToConstant: 70).isActive = true
        blank.heightAnchor.constraint(equalToConstant: 40).isActive = true
        blank.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blank.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blank.layer.borderColor = UIColor.black.cgColor
        blank.layer.borderWidth = 1
        blank.font = UIFont.systemFont(ofSize: 10)
        
        info.widthAnchor.constraint(equalToConstant: 200).isActive = true
        info.heightAnchor.constraint(equalTo: blank.heightAnchor).isActive = true
        info.leftAnchor.constraint(equalTo: blank.rightAnchor, constant: 10).isActive = true
        info.topAnchor.constraint(equalTo: blank.topAnchor).isActive = true
        info.layer.borderColor = UIColor.black.cgColor
        info.layer.borderWidth = 1
        info.borderStyle = .roundedRect
        info.doInset()
        info.autocorrectionType = .no
        info.autocapitalizationType = .none
        info.clearButtonMode = .whileEditing
        info.backgroundColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
class GenderCell: UITableViewCell {
    var info : UIView = UIView()
    var blank : regLabel = regLabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        blank.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blank)
        self.addSubview(info)
        blank.widthAnchor.constraint(equalToConstant: 70).isActive = true
        blank.heightAnchor.constraint(equalToConstant: 40).isActive = true
        blank.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blank.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blank.layer.borderColor = UIColor.black.cgColor
        blank.layer.borderWidth = 1
        blank.font = UIFont.systemFont(ofSize: 10)
        
        info.widthAnchor.constraint(equalToConstant: 200).isActive = true
        info.heightAnchor.constraint(equalTo: blank.heightAnchor).isActive = true
        info.leftAnchor.constraint(equalTo: blank.rightAnchor, constant: 10).isActive = true
        info.topAnchor.constraint(equalTo: blank.topAnchor).isActive = true
        info.layer.borderColor = UIColor.black.cgColor
        info.layer.borderWidth = 1
        info.backgroundColor = .red
        
        let male = UIButton(type: .system)
        let female = UIButton(type: .system)
        let nonb = UIButton(type: .system)
        
        info.addSubview(male)
        info.addSubview(female)
        info.addSubview(nonb)
        
        male.translatesAutoresizingMaskIntoConstraints = false
        female.translatesAutoresizingMaskIntoConstraints = false
        nonb.translatesAutoresizingMaskIntoConstraints = false
        
        male.widthAnchor.constraint(equalToConstant: 5).isActive = true
        male.heightAnchor.constraint(equalToConstant: 5).isActive = true
        male.leftAnchor.constraint(equalTo: info.leftAnchor).isActive = true
        male.topAnchor.constraint(equalTo: info.topAnchor).isActive = true
        female.widthAnchor.constraint(equalToConstant: 5).isActive = true
        female.heightAnchor.constraint(equalToConstant: 5).isActive = true
        female.leftAnchor.constraint(equalTo: info.leftAnchor).isActive = true
        female.topAnchor.constraint(equalTo: info.topAnchor).isActive = true
        nonb.widthAnchor.constraint(equalToConstant: 5).isActive = true
        nonb.heightAnchor.constraint(equalToConstant: 5).isActive = true
        nonb.leftAnchor.constraint(equalTo: info.leftAnchor).isActive = true
        nonb.topAnchor.constraint(equalTo: info.topAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class regLabel : UILabel {
    override open func draw(_ rect: CGRect) {
        let inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.drawText(in: rect.inset(by: inset))
    }
}
