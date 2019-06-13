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
}

class TextCell: RegisterCell{
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
class GenderCell: RegisterCell {
    var info : UIView = UIView()
    var blank : regLabel = regLabel()
    var buttons : [DLRadioButton] = []
    var labels : [UILabel] = []
    var choice : Int = -1
    
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
        
        info.widthAnchor.constraint(equalToConstant: 300).isActive = true
        info.heightAnchor.constraint(equalTo: blank.heightAnchor).isActive = true
        info.leftAnchor.constraint(equalTo: blank.rightAnchor, constant: 10).isActive = true
        info.topAnchor.constraint(equalTo: blank.topAnchor).isActive = true
        info.layer.borderColor = UIColor.black.cgColor
        info.layer.borderWidth = 1
        info.backgroundColor = .white
        
        let male = DLRadioButton()
        let female = DLRadioButton()
        let nonb = DLRadioButton()
        let buttonW = CGFloat(integerLiteral: 30)
        let buttonH = CGFloat(integerLiteral: 30)
        buttons.append(male)
        buttons.append(female)
        buttons.append(nonb)
        
        info.addSubview(male)
        info.addSubview(female)
        info.addSubview(nonb)
        
        prepareButton(b: male, msg: "male")
        prepareButton(b: female, msg: "female")
        prepareButton(b: nonb, msg: "non-binary")
        
        male.translatesAutoresizingMaskIntoConstraints = false
        female.translatesAutoresizingMaskIntoConstraints = false
        nonb.translatesAutoresizingMaskIntoConstraints = false
        
        male.widthAnchor.constraint(equalToConstant:buttonW).isActive = true
        male.heightAnchor.constraint(equalToConstant: buttonH).isActive = true
        male.leftAnchor.constraint(equalTo: info.leftAnchor, constant: 10).isActive = true
        male.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        female.widthAnchor.constraint(equalToConstant: buttonW).isActive = true
        female.heightAnchor.constraint(equalToConstant: buttonH).isActive = true
        female.leftAnchor.constraint(equalTo: male.rightAnchor, constant: 30).isActive = true
        female.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        nonb.widthAnchor.constraint(equalToConstant: buttonW).isActive = true
        nonb.heightAnchor.constraint(equalToConstant:buttonH).isActive = true
        nonb.leftAnchor.constraint(equalTo: female.rightAnchor, constant: 30).isActive = true
        nonb.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        
        male.addTarget(self, action: #selector(maleChosen), for: .touchUpInside)
        female.addTarget(self, action: #selector(femaleChosen), for: .touchUpInside)
        nonb.addTarget(self, action: #selector(nonbChosen), for: .touchUpInside)
        
        setupLabel()
        
    }
    private func prepareButton(b: DLRadioButton, msg: String) {
        //b.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        let color = MAIN_TINT6
        b.iconColor = color.withAlphaComponent(0.8)
        b.indicatorColor = color.withAlphaComponent(1)
        b.isIconSquare = false
        b.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
    }
    private func setupLabel() {
        let ml = regLabel()
        ml.text = "male"
        ml.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let fl = regLabel()
        fl.text = "female"
        fl.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let nbl = regLabel()
        nbl.text = "non-binary"
        nbl.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        info.addSubview(ml)
        info.addSubview(fl)
        info.addSubview(nbl)
        
        ml.translatesAutoresizingMaskIntoConstraints = false
        fl.translatesAutoresizingMaskIntoConstraints = false
        nbl.translatesAutoresizingMaskIntoConstraints = false
        
        ml.adjustsFontSizeToFitWidth = true
        fl.adjustsFontSizeToFitWidth = true
        nbl.adjustsFontSizeToFitWidth = true
        
        ml.widthAnchor.constraint(equalToConstant: 100)
        ml.leftAnchor.constraint(equalTo: buttons[0].rightAnchor, constant: -5).isActive = true
        ml.heightAnchor.constraint(equalToConstant: 20).isActive = true
        ml.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        fl.widthAnchor.constraint(equalToConstant: 100)
        fl.leftAnchor.constraint(equalTo: buttons[1].rightAnchor, constant: -5).isActive = true
        fl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fl.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        nbl.widthAnchor.constraint(equalToConstant: 150)
        nbl.leftAnchor.constraint(equalTo: buttons[2].rightAnchor, constant: -5).isActive = true
        nbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        nbl.centerYAnchor.constraint(equalTo: info.centerYAnchor).isActive = true
        
    }
    @objc private func maleChosen() {
        buttons[1].isSelected = false
        buttons[2].isSelected = false
        choice = 0
    }
    @objc private func femaleChosen() {
        buttons[0].isSelected = false
        buttons[2].isSelected = false
        choice = 1
    }
    @objc private func nonbChosen() {
        buttons[0].isSelected = false
        buttons[1].isSelected = false
        choice = 2
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
