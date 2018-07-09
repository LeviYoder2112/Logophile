//
//  ViewController.swift
//  Todoey
//
//  Created by Levi Yoder on 4/9/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController{
   
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewWord" {
         let destinationVC = segue.destination as! FlashCardViewController
                    if let indexPath = tableView.indexPathForSelectedRow {
                        destinationVC.selectedWord = toDoWords?[indexPath.row]
                    }
        } else if segue.identifier == "quizSegue" {
        let destinationVC = segue.destination as! QuizViewController
        destinationVC.chosenCategory = selectedCategory
        }}

    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadWords()
        }
    }
    
    var toDoWords: Results<Word>?
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
         super.viewDidLoad()
         tableView.rowHeight = 80.0
        self.navigationController?.isToolbarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
 
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return toDoWords?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
       
        if let word = toDoWords?[indexPath.row] {
           
            cell.textLabel?.text = word.title        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }

    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let word = toDoWords?[indexPath.row]
        print(word?.title)
        performSegue(withIdentifier: "viewWord", sender: self)
    }
    


    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message : "", preferredStyle : .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                
                        let sentence = textField.text
                        let wordList =  sentence?.components(separatedBy: .punctuationCharacters).joined().components(separatedBy: " ").filter{!$0.isEmpty}
                        print(wordList?.count)
                        var numberOfWords = wordList!.count
                        if numberOfWords == 1 {
                            
                            
                            
                            
                            let newWord = Word()
                            newWord.dateCreated = Date()
                            newWord.title = textField.text!
                            currentCategory.words.append(newWord)
                            print(newWord.dateCreated)
                        } else {
                            
                           
        let alert2 = UIAlertController(title: "Oops!", message: "You can only add one word at a time to your list!", preferredStyle : .alert)

                            alert2.addAction(UIAlertAction(title: "Okay!", style: .default, handler: nil))
                            self.present(alert2, animated: true)
        
                            
                        }
                        }
                        
                    
                } catch{
                    print("Error saving new items")
                }
            }
self.tableView.reloadData()
           
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
           textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Data Manipulation

    func loadWords(){
toDoWords = selectedCategory?.words.sorted(byKeyPath: "dateCreated", ascending: true)
}

    override func updateModel(at indexPath: IndexPath) {
        if let wordsForDeletion = toDoWords?[indexPath.row] {
            
            do {
                try realm.write {
                    realm.delete(wordsForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
            
            tableView.reloadData()
            
        }
    }

    
        
    
}


// MARK: - Search bar Methods

//extension ToDoListViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked1(_ searchBar: UISearchBar) {
//        toDoWords = toDoWords?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
//
//        tableView.reloadData()
//
//    }
//    func searchBar1(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadWords()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}

