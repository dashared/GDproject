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
        CellData(opened: false, title: "Published", sectionData: ["Книга 1", "Книга 2", "Книга 3"]),
        CellData(opened: false, title: "Courses", sectionData: ["Курс 1", "Курс 2"]),
        CellData(opened: false, title: "Link", sectionData: ["https://wwww.hse.ru"])
    ]
    
    var type: HeaderType = .BASIC_INFO("Profile", "Basic info")

    var viewController: ProfileViewController?
    
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
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: basicInfoCellId, for: indexPath) as! BasicInfoCell
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 46
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerNewsChannelsVC) as! HeaderNewsChannels

            cell.vcProfile = viewController

            cell.type = type

            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46.0))
            view.addSubview(cell)
            cell.edgesToSuperview()

            return view
        }
        return nil
    }
}
