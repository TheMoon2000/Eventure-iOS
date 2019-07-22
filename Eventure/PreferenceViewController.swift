//
//  PreferenceViewController.swift
//  Eventure
//
//  Created by Xiang Li on 7/21/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController {
    var preferences = ["music","sports","academics","professional","culture","workshop","tech",
                       "politics","religious","recruiting","seminar","arts","outdoor","photography","party"]
    var cnt : Int = 0
    let text = UITextView()
    var navBar: UINavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        makeTextView()
        makeButtons()
    }
    

    private func makeTextView(){
        
        text.text = "Pick 3 favorite topics to build \nyour own event network"
        text.adjustsFontForContentSizeCategory = true
        text.font = .boldSystemFont(ofSize: 26)
        text.textColor = MAIN_TINT
        text.isEditable = false
        
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        text.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        text.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        text.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        text.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    private func makeButtons(){
        let space = UIStackView()
        space.axis = .vertical
        space.distribution = .equalCentering
        space.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(space)
        space.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        space.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10).isActive = true
        space.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        space.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        space.setBackGroundColor(color: MAIN_TINT)
        space.alpha = 0.7
        
        let perRow = 3
        assert(preferences.count % perRow == 0, "you don't have the right number of preferences")
        
        var counter = 0
        
        var row : UIStackView?
        for p in preferences {
            let b = UIButton()
            b.setTitle(p, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 17.2, weight: .semibold)
            b.tintColor = .white
            b.backgroundColor = .init(white: 1, alpha: 0.05)
            b.layer.borderColor = UIColor.white.cgColor
            b.layer.borderWidth = 1.0
            b.translatesAutoresizingMaskIntoConstraints = true
            let diameter : CGFloat = 40
            
            b.widthAnchor.constraint(equalToConstant: diameter)
            b.heightAnchor.constraint(equalToConstant: diameter)
            b.layer.cornerRadius = diameter/2
            b.addTarget(self, action: #selector(choose(_:)), for: .touchUpInside)
            if (counter < 3) {
                if (counter == 0) {
                    row = UIStackView()
                    row!.axis = .horizontal
                    row!.distribution = .fillEqually
                    row!.translatesAutoresizingMaskIntoConstraints = false
                    row!.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
                    row!.heightAnchor.constraint(equalToConstant: 80).isActive = true
                }
                row!.addArrangedSubview(b)
                counter += 1
                if (counter == 3) {
                    space.addArrangedSubview(row!)
                    counter = 0
                }
            }
        }
        
    }
    @objc private func choose(_ sender: UIButton) {
        if (sender.isSelected == false) {
            cnt += 1
            sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
            sender.backgroundColor = .clear
            sender.isSelected = true
        } else {
            cnt -= 1
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = .init(white: 1, alpha: 0.05)
            sender.isSelected = false
        }
        
        if (cnt == 3) {
            let nextVC = MainTabBarController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }

}
extension UIStackView {
    func setBackGroundColor(color: UIColor) {
        let tempView = UIView(frame: bounds)
        tempView.backgroundColor = color
        tempView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(tempView, at: 0)
    }
}
