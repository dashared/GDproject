//
//  FacultyTableViewController.swift
//  GDproject
//
//  Created by cstore on 10/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol ChosenFactulty: class {
    func onChooseFaculty(faculty: Model.Faculty)
}

class FacultyTableViewController: UITableViewController {
    
    weak var delegate: ChosenFactulty?
    
    var currentFaculties: [Model.Faculty] = []{
        didSet {
            tableView.reloadData()
        }
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Faculties"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        setUpTimer()
    }
    
    func setUpTimer(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            DispatchQueue.main.async { [weak self] in
                
                if self!.isFiltering {
                    Model.searchFaculty(string: (self?.searchController.searchBar.text)!) { [weak self] in
                        self?.currentFaculties = $0
                    }
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentFaculties.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "F", for: indexPath)
        
        cell.textLabel?.text = currentFaculties[indexPath.row].name
        cell.detailTextLabel?.text = currentFaculties[indexPath.row].campusName
        cell.selectionStyle = .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onChooseFaculty(faculty: currentFaculties[indexPath.row])
        searchController.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
