//
//  QuizViewController.swift
//  Dictionary Flash
//
//  Created by Levi Yoder on 7/3/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class QuizViewController : UIViewController {
    
    @IBOutlet weak var quizWordLabel: UILabel!
    var count = 0
    var numberCorrect = 0
    var randomIndex1 = 0
    var randomIndex2 = 0
    var randomIndex3 = 0
    var categoryName = ""
    var randomNumber = 0
    var wordsArray = realm.objects(Word.self)
    var toDoWords: Results<Word>?
    var chosenCategory : Category? {
        didSet{
            loadWords()
            categoryName = (chosenCategory?.name)!
           }
    }
     var wordPool = realm.objects(Word.self)

    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        updateDisplay()
       setTitles()
resetHasBeenQuizzed()
    }
   
    
    func loadWords(){
    toDoWords = chosenCategory?.words.sorted(byKeyPath: "title", ascending: true)
   
    }
    
    
    func updateDisplay() {
     randomNumber = Int(arc4random_uniform(3))
   // let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
        let predicate = NSPredicate(format: "category = %@ AND hasBeenQuizzed == %@", categoryName, NSNumber(value: false))
        wordPool = realm.objects(Word.self).filter(predicate).sorted(byKeyPath: "title", ascending: true)
   
    //Picking 3 random (and not repeating)word definitions to display
    count = wordPool.count
    randomIndex1 = Int(arc4random_uniform(UInt32(count)))
            randomIndex2 = Int(arc4random_uniform(UInt32(count)))
           randomIndex3 = Int(arc4random_uniform(UInt32(count)))
        repeat {
            randomIndex2 = Int(arc4random_uniform(UInt32(count)))
        } while randomIndex2 == randomIndex1 || randomIndex2 == randomIndex3
        repeat {
            randomIndex3 = Int(arc4random_uniform(UInt32(count)))
        } while randomIndex3 == randomIndex2 || randomIndex3 == randomIndex1
   
        
        let quizWord1 = wordPool[randomIndex1]
    let quizWord2 = wordPool[randomIndex2]
    let quizWord3 = wordPool[randomIndex3]
    
            self.quizWordLabel.text = quizWord1.title
      
        
        if quizWord1.definition == "" {
                self.getDefinition(word: (quizWord1.title), randomIndex: self.randomIndex1)}
           
            if quizWord2.definition == "" {
                self.getDefinition(word: (quizWord2.title), randomIndex: self.randomIndex2)}
       
            if quizWord3.definition == "" {
                self.getDefinition(word: (quizWord3.title), randomIndex: self.randomIndex3)}
           

       
        
        
      
      
        setTitles()
    
    }
    
    func getDefinition(word: String, randomIndex: Int) {
        
        let appId = "219ad5f4"
        let appKey = "6e3ee9bd554aecdf493aebe931043b6b"
        let language = "en"
        let word_id = word.lowercased()
    if let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word)"){
        
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(appId, forHTTPHeaderField: "app_id")
            request.addValue(appKey, forHTTPHeaderField: "app_key")
            
            let session = URLSession.shared
            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                if let response = response,
                    let data = data,
                    let jsonData = try? JSON(JSONSerialization.jsonObject(with: data, options: .mutableContainers)) {
                    //print(jsonData)
                    self.parseDefinition(json: jsonData, randomIndex: randomIndex)
    } else {
                                    print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
                    print(response)
                    print(error)
                    DispatchQueue.main.sync {
                                   //             self.definitionField.text = "Not able to fetch definition. Check connection, and/or spelling!"
                    }}
            }).resume()
        }}

    func parseDefinition(json : JSON, randomIndex : Int) {
let definitionResult = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"]
  DispatchQueue.main.sync {
    if let definitionAsString = definitionResult.rawString() {
        do{
            try realm.write {
                toDoWords?[randomIndex].definition = definitionAsString
            }
        } catch {
            print("error saving definition to realm file\(error)")
        }}
    setTitles()
        }

    
        
    
    
    
    }
    func setTitles() {
       
     
        if randomNumber == 0 {
            
                option1.setTitle(wordPool[randomIndex1].definition, for: .normal)
                option2.setTitle(wordPool[randomIndex2].definition, for: .normal)
                option3.setTitle(wordPool[randomIndex3].definition, for: .normal)
            
        } else if randomNumber == 1 {
            
                option1.setTitle(wordPool[randomIndex3].definition, for: .normal)
                option2.setTitle(wordPool[randomIndex1].definition, for: .normal)
                option3.setTitle(wordPool[randomIndex2].definition, for: .normal)
            
        } else if randomNumber == 2 {
            
                option1.setTitle(wordPool[randomIndex2].definition, for: .normal)
                option2.setTitle(wordPool[randomIndex3].definition, for: .normal)
                option3.setTitle(wordPool[randomIndex1].definition, for: .normal)
            }
    }
    
    func resetHasBeenQuizzed(){
       let predicate = NSPredicate(format: "category = %@", categoryName)
        do {
            try realm.write {
                let words = realm.objects(Word.self).filter(predicate)
            words.setValue(false, forKey: "hasBeenQuizzed")
            }} catch{
                print("unable to update hasBeenQuizzed\(error)")
        }
    }

    //buttons have been pressed!
    
    @IBAction func option1pressed(_ sender: UIButton) {
      
    }
    
    @IBAction func option2pressed(_ sender: UIButton) {
        
       
    }
    
    @IBAction func option3pressed(_ sender: UIButton) {
      
    }
    @IBOutlet weak var option1: UIButton!
    
    @IBOutlet weak var option2: UIButton!
    
    @IBOutlet weak var option3: UIButton!




}
