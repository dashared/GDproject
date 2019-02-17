//
//  BasicInfoController.swift
//  GDproject
//
//  Created by cstore on 16/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

struct CellData{
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class BasicInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var dataSourse: [CellData] = [
        CellData(opened: false, title: "Phone", sectionData: ["+7 901 733 01 79"]),
        CellData(opened: false, title: "Mail", sectionData: ["vbogomazova@edu.hse.ru"]),
        CellData(opened: false, title: "Research ID", sectionData: ["4567834336789456737"]),
        CellData(opened: false, title: "Published", sectionData: ["Это будет очень длинное название книги 1, чтобы сделать проверку", "Книга 2", "Книга 3"]),
        CellData(opened: false, title: "Courses", sectionData: ["Курс 1", "Курс 2"]),
        CellData(opened: false, title: "Link", sectionData: ["https://wwww.hse.ru"])
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataSourse[section].opened){
            return dataSourse[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: basicInfoCellId, for: indexPath) as! BasicInfoCell
            cell.fill(title: dataSourse[indexPath.section].title)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as!  InfoCell
            cell.fill(title: dataSourse[indexPath.section].sectionData[indexPath.row - 1])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if dataSourse[indexPath.section].opened {
                dataSourse[indexPath.section].opened = false
                let section = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(section, with: .none)
            } else {
                dataSourse[indexPath.section].opened = true
                let section = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(section, with: .none)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
