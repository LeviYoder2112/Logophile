//
//  ViewController.swift
//  Todoey
//
//  Created by Levi Yoder on 4/9/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

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
        self.navigationController?.navigationBar.tintColor = UIColor.white;
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
        
        let alert = UIAlertController(title: "Add New Word", message : "", preferredStyle : .alert)
        
        let action = UIAlertAction(title: "Add Word", style: .default){ (action) in
         
            if let currentCategory = self.selectedCategory{
           
                
                let entry = textField.text
                let wordList =  entry?.lowercased().components(separatedBy: .punctuationCharacters).joined().components(separatedBy: " ").filter{!$0.isEmpty}
                var numberOfWords = wordList!.count
               
                if numberOfWords == 1 {
                   
                    let appId = "219ad5f4"
                    let appKey = "6e3ee9bd554aecdf493aebe931043b6b"
                    let language = "en"
                    let word_id = entry?.lowercased() //word id is case sensitive and lowercase is required
                   print(word_id)
//                  if let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word!)")
                    if let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/inflections/\(language)/\(word_id!)"){
var request = URLRequest(url: url)
                                            request.addValue("application/json", forHTTPHeaderField: "Accept")
                                            request.addValue(appId, forHTTPHeaderField: "app_id")
                                            request.addValue(appKey, forHTTPHeaderField: "app_key")
                                            
                                            let session = URLSession.shared
                                            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                                                if let response = response,
                                                    let data = data,
                                                    let jsonData = try? JSON(JSONSerialization.jsonObject(with: data, options: .mutableContainers)) {
                                                    print(response)
                                                    print(jsonData)

                                                    let inflectedFrom = self.parseInterpretation(json: jsonData, entry: word_id!)
                                                 print("inflectedFrom is \(inflectedFrom)")
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                    
                                                    do{
                                                        try self.realm.write {
                                                            let newWord = Word()
                                                            newWord.dateCreated = Date()
                                                            newWord.title = inflectedFrom
                                                            currentCategory.words.append(newWord)
                                                            newWord.category = currentCategory.name
                                                        }
                                                    } catch {
                                                      print("error saving inflected word to Realm")
                                                        }
                                                        self.tableView.reloadData()
                                                        
                                                    }
                                                } else {
                                                    print(error)
                                                    DispatchQueue.main.async {
                                                        
                                                        
                                                        do{
                                                            try self.realm.write {
                                                                let newWord = Word()
                                                                newWord.dateCreated = Date()
                                                                newWord.title = word_id!
                                                                currentCategory.words.append(newWord)
                                                                newWord.category = currentCategory.name
                                                            }
                                                        } catch {
                                                            print("error saving inflected word to Realm")
                                                        }
                                                        self.tableView.reloadData()
                                                        
                                                    }
//                                                    print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
                                                }
                                            }).resume()
                    }
                                            
                    
                    } else {
                            let alert2 = UIAlertController(title: "Oops!", message: "You can only add one word at a time to your list!", preferredStyle : .alert)

                            alert2.addAction(UIAlertAction(title: "Okay!", style: .default, handler: nil))
                            self.present(alert2, animated: true)
        
                            
                        }
                        }
                        self.tableView.reloadData()
           
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
           textField = alertTextField
        }
        
        alert.addAction(action)
     let action2 = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
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

    
    // MARK: - Parsing JSON
    
    func parseInterpretation(json : JSON, entry: String) -> String {

let interpretation = json["results"][0]["lexicalEntries"][0]["inflectionOf"][0]["id"]
        let interpretationAsString = interpretation.rawString()
        return interpretationAsString ?? entry
       }
    
}


// MARK: - Search bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoWords = toDoWords?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadWords()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        
        }
    }

}



