//
//  RegisterTableViewController.swift
//  GDproject
//
//  Created by cstore on 10/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class RegisterTableViewController: UITableViewController, ChosenFactulty
{
    
    func presentAlertInvalidData()
    {
        let alert = UIAlertController(title: "Invalid data", message: "Some fields are missing. Add more information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onChooseFaculty(faculty: Model.Faculty) {
        self.faculty = faculty
        tableView.reloadData()
    }
    

    var onRegistration: (()->())?
    
    var faculty: Model.Faculty?
    var user: Model.NewRegistration = Model.NewRegistration(email: DataStorage.standard.getEmail()!, firstName: nil, middleName: nil, lastName: nil, faculty: nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        navigationItem.title = user.email
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endRegistration))
    }

    @objc func endRegistration()
    {
        updateUser()
        guard let faculty = faculty else { presentAlertInvalidData(); return }
        
        user.faculty = faculty.url
        
        guard let _ = user.firstName else { presentAlertInvalidData(); return  }
        guard let _ = user.middleName else { presentAlertInvalidData(); return  }
        guard let _ = user.lastName else { presentAlertInvalidData(); return  }
        
        Model.register(object: user)
        { [weak self] in
            self?.onRegistration?()
        }
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 3
        default:
            if let _ = faculty {
                return 2
            } else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section {
        case 0:
            return "Initials"
        default:
            return "Faculty"
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath) as! InititalsViewCell
            switch indexPath.row{
            case 0:
                if let name = user.firstName {
                    cell.fill(with: name)
                } else {
                    cell.initialsTextField.placeholder = "First name"
                }
            case 1:
                if let name = user.middleName {
                    cell.fill(with: name)
                } else {
                    cell.initialsTextField.placeholder = "Middle name"
                }
            default:
                if let name = user.lastName {
                    cell.fill(with: name)
                } else {
                    cell.initialsTextField.placeholder = "Last name"
                }
            }
            cell.selectionStyle = .none
            return cell
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell111", for: indexPath)
                cell.selectionStyle = .none
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "facultyCell", for: indexPath)
                cell.textLabel?.text = faculty!.name
                cell.detailTextLabel?.text = faculty!.campusName
                cell.selectionStyle = .none
                return cell
            }
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            
            updateUser()
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "FacultyTableViewController") as! FacultyTableViewController
            
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updateUser(){
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InititalsViewCell else {return}
        guard let cell1 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InititalsViewCell else {return}
        guard let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? InititalsViewCell else {return}
        
        user.firstName = cell.initialsTextField.text!
        user.middleName = cell1.initialsTextField.text!
        user.lastName = cell2.initialsTextField.text!
    }

}
