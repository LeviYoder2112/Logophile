//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Levi Yoder on 4/17/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import CoreData

var categoryArray = [Category]()

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Categories.plist")

class CategoryViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    loadCategories()
        
    }
    
    
 
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categoryArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    
        cell.textLabel?.text = categoryArray[indexPath.row].name
    
        return cell
    }
    
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
    
        if let indexPath = tableView.indexPathForSelectedRow {
        destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category. \(error)")
        }
    tableView.reloadData()
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching categories from context. \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Add new categories
@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textField = UITextField()
    
    let alert = UIAlertController(title: "Add New Category", message : "", preferredStyle : .alert)
    
    let action = UIAlertAction(title: "Add", style: .default){ (action) in
        
        let newCategory = Category(context: context)
        newCategory.name = textField.text!
categoryArray.append(newCategory)
        self.saveCategories()
        }

    alert.addAction(action)
    
    alert.addTextField { (field) in
        textField = field
textField.placeholder = "Add new category"
        
    }
    present(alert, animated: true, completion: nil)
    }


}




