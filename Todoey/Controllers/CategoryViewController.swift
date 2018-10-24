//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Levi Yoder on 4/17/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift


let realm = try! Realm()

var categories: Results<Category>?

class CategoryViewController: SwipeTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    tableView.rowHeight = 80.0
        loadCategories()
       
    }
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories"
cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 23)
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
    
        if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }} catch {
            print("Error saving category. \(error)")
        }
    tableView.reloadData()
    }
    
    func loadCategories() {

         categories = realm.objects(Category.self)
        
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
                        if let categoryForDeletion = categories?[indexPath.row] {
        
                            do {
                                try realm.write {
                                    realm.delete(categoryForDeletion)
                                }
                            } catch {
                                print("Error deleting category, \(error)")
                            }
        
                            tableView.reloadData()
        
                        }
    }
    
    // MARK: - Add new categories
@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textField = UITextField()
    
    let alert = UIAlertController(title: "Add New Category", message : "", preferredStyle : .alert)
    
    let action = UIAlertAction(title: "Add", style: .default){ (action) in
     
       
        let newCategory = Category()
       
        newCategory.name = textField.text!
        self.save(category: newCategory)
        }

    alert.addAction(action)
       let action2 = UIAlertAction(title: "Cancel", style: .cancel)
    alert.addAction(action2)
    alert.addTextField { (field) in
        textField = field
textField.placeholder = "Add new category"
        
        
    }
    present(alert, animated: true, completion: nil)
    tableView.reloadData()
    }
    }




