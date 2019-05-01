//
//  PeopleToWriteViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class PeopleToWriteViewController: UITableViewController {
    
    let searchC = UISearchController(searchResultsController: nil)
    
    let users = [(id: 9,name: "Anna Mikhaleva")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "People"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.searchController = searchC
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleToWriteCell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = "\(users[indexPath.row].id)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        
        guard let _ = self.navigationController?.viewControllers.lastIndex(of: self) else
        {
            (navigationController?.viewControllers.last as? MessagesViewController)?.currentActiveDialogs.append(users[indexPath.row])
            (navigationController?.viewControllers.last as? MessagesViewController)?.onDialogDisplay?(users[indexPath.row])
            return
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
