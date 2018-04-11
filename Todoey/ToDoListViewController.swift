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
    
    var itemArray = [Item]()
    
    override func viewDidLoad() {
        
        let newItem = Item()
        newItem.title = "Pet Cleo"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Walk Cleo"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Feed Cleo"
        itemArray.append(newItem3)
   
           if let items = defaults.array(forKey: "ToDoListArray") as? [Item]{
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
        
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done == true ? .checkmark : .none
       
        return cell
    }

    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print(itemArray[indexPath.row])
      
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
      
        
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
            
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
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

