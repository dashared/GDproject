//
//  SettingsViewController.swift
//  GDproject
//
//  Created by cstore on 16/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    var dataSourse: [String] = ["Пригласить преподавателя"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataSourse[indexPath.row]  == "Пригласить преподавателя" {
            let vc = storyboard?.instantiateViewController(withIdentifier: inviteVC) as! InviteViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = dataSourse[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

}
