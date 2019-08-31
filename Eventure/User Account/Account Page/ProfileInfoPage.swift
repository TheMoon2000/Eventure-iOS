//
//  ProfileInfoPage.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class ProfileInfoPage: UITableViewController {
    
    private var graduationCellExpanded = false
    private var contentCells = [[UITableViewCell]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: .zero, style: .grouped)
        
        var section0 = [UITableViewCell]()
        
        let nameCell = TextFieldCell()
        nameCell.icon.image = #imageLiteral(resourceName: "name")
        nameCell.textfield.placeholder = "Full Name"
        nameCell.textfield.textContentType = .name
        nameCell.textfield.autocapitalizationType = .words
        
        nameCell.endEditingHandler = { textfield in
            User.current?.fullName = textfield.text!
        }
        
        nameCell.returnHandler = { textfield in
            textfield.resignFirstResponder()
        }
        
        section0.append(nameCell)
        
        let gradCell = SettingsItemCell()
        gradCell.icon.image = #imageLiteral(resourceName: "graduation")
        gradCell.titleLabel.text = "Year of Graduation"
        gradCell.valueLabel.text = User.current!.graduation
        section0.append(gradCell)
        
        let chooser = GraduationYearChooser()
        chooser.selectionHandler = { year, season in
            User.current?.yearOfGraduation = year
            User.current?.seasonOfGraduation = season
        }
        section0.append(chooser)
        
        contentCells.append(section0)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section != 0 { return nil }
        
        let header = UIView()
        
        let title = UILabel()
        title.numberOfLines = 5
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.attributedText = "Let recruiters know more about you at event check-ins by filling out your profile information!".attributedText()
        title.font = .systemFont(ofSize: 17)
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)
        
        title.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30).isActive = true
        title.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30).isActive = true
        title.topAnchor.constraint(equalTo: header.topAnchor, constant: 20).isActive = true
        title.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20).isActive = true
        
        return header
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contentCells.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [nil, "Links"][section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contentCells[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0, 2] {
            return graduationCellExpanded ? 230 : 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return contentCells[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case [0, 1]:
            view.endEditing(true)
            graduationCellExpanded.toggle()
            
            let chooserCell = contentCells[0][2] as! GraduationYearChooser
            chooserCell.isUserInteractionEnabled = graduationCellExpanded
            
            UIView.animate(withDuration: 0.2) {
                chooserCell.picker.alpha = self.graduationCellExpanded ? 1.0 : 0.0
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }
    

}
