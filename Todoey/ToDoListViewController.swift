//
//  ViewController.swift
//  Todoey
//
//  Created by Levi Yoder on 4/9/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    let defaults = UserDefaults.standard
    
    var itemArray = ["Pet Cleo", "Walk Cleo", "Give Cleo a Bone"]
    override func viewDidLoad() {
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [String]{
            itemArray = items
        }
        super.viewDidLoad()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
 
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
      
        cell.textLabel?.text = itemArray[indexPath.row]
       
        return cell
    }

    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
      
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message : "", preferredStyle : .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            //what happens when our Add Item is pressed in the alert
            self.itemArray.append(textField.text!)
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
           textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    
    }
}

