//
//  ChatInfoViewController.swift
//  GDproject
//
//  Created by cstore on 02/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

/// Class for displaying chat info
/// 
class ChatInfoViewController: UITableViewController {
    
    enum PersonStatus{
        case admin
        case ordinary
    }
    
    weak var delegate: UpdatableGroup?
    
    var groupChat: Model.Group? {
        didSet{
            if let groupChat = groupChat {
                usersArray = groupChat.users.map { $0.key }
            }
        }
    }
    
    var usersArray: [Int] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var users: [Int: Model.Users] = [:]
    
    func canIEditThisChat() -> PersonStatus
    {
        let myId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.id.rawValue)
        
        if let groupChatUserPermission = groupChat?.users[myId]?.isAdmin {
           return groupChatUserPermission ?  .admin :  .ordinary
        }
        
        return .ordinary
    }
    
    var myPermissions: PersonStatus = .ordinary
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myPermissions = canIEditThisChat()
        tableView.reloadData()
        
        switch myPermissions {
        case .admin:
            navigationItem.rightBarButtonItem = self.editButtonItem
        default:
            return
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return usersArray.count + (myPermissions == .ordinary ? 0 : 1)
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.row == 0 {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = groupChat!.name
                return cell
            case 1:
                cell.textLabel?.text = "Leave chat"
                cell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                return cell
            default:
                switch myPermissions{
                case .admin:
                    cell.textLabel?.text = "Add participants"
                    cell.accessoryType = .disclosureIndicator
                case .ordinary:
                    cell.textLabel?.text = name(for: users[usersArray[indexPath.row]])
                }
                return cell
            }
        }
        
        switch myPermissions{
        case .admin:
            cell.textLabel?.text = name(for: users[usersArray[indexPath.row-1]])
        case .ordinary:
            cell.textLabel?.text = name(for: users[usersArray[indexPath.row]])
        }

        return cell
    }
    
    private func name(for user: Model.Users?) -> String {
        if let user = user, let perm = groupChat?.users[user.id]?.isAdmin {
            if perm {
                return "🤴🏻 \(user.fullName())"
            }
            return "👤 \(user.fullName())"
        }
        
        return "left"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section {
        case 0:
            return "Title"
        case 1:
            return "Opportunities"
        default:
            return "Participants"
        }
    }
 

    func editName(for cell: UITableViewCell){
        let alert = UIAlertController(title: "Вы уверены?", message: "Название:", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Oтмена", style: .cancel, handler: nil)
        
        alert.addTextField { [weak self] (tf) in
            tf.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tf.text = self?.groupChat?.name
        }
        
        let action2 = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            let name = alert.textFields?.first?.text
            cell.textLabel?.text = name
            self.groupChat?.name = name!
            Model.updateGroupChat(with: self.groupChat!)
            self.delegate?.updateGroup(with: self.groupChat!)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let groupChat = groupChat else {
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        if indexPath.row == 0 {
            switch indexPath.section{
            case 0:
                switch myPermissions{
                case .admin:
                    editName(for: cell)
                default:
                    break
                }
            case 1:
                Model.leaveGroupChat(id: groupChat.id) {
                    [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            default:
                switch myPermissions{
                case .admin:
                    showUserChoiceVC()
                default:
                    break
                }
            }
        }
    }
    
    func showUserChoiceVC()
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: peopleToWriteVC) as! PeopleToWriteViewController
        
        vc.whatToDoWithSelection = { [weak self, weak vc] mapa in
            
            mapa.forEach { self?.users[$0.key] = Model.Channels.fullPeopleDict[$0.key] }
            mapa.forEach { self?.groupChat?.users[$0.key] = $0.value }
            vc?.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            groupChat?.users[usersArray[indexPath.row-1]] = nil
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let editButton = UITableViewRowAction(style: .normal, title: "Promote") { [unowned self] (rowAction, indexPath) in
            
            self.tableView.beginUpdates()
            self.groupChat?.users[self.usersArray[indexPath.row-1]]?.isAdmin = true
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
        
        editButton.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
        
        let restrictButton = UITableViewRowAction(style: .normal, title: "Restrict") { [unowned self] (rowAction, indexPath) in
            
            self.tableView.beginUpdates()
            self.groupChat?.users[self.usersArray[indexPath.row-1]]?.isAdmin = false
            self.tableView.reloadRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
        
        restrictButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { [unowned self] (action, indexPath) in
            
            self.tableView.beginUpdates()
            self.groupChat?.users[self.usersArray[indexPath.row-1]] = nil
            self.tableView.deleteRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
        
        deleteButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [editButton, restrictButton, deleteButton]
    }
    
    /// update chatInfo
    override func viewWillDisappear(_ animated: Bool) {
        
        defer {
            super.viewWillDisappear(animated)
        }
        
        guard let _ = self.navigationController?.viewControllers.lastIndex(of: self) else {
            switch myPermissions {
            case .ordinary:
                return
            case .admin:
                Model.updateGroupChat(with: groupChat!)
                delegate?.updateGroup(with: groupChat!)
            }
            return
        }
    }
}
