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
   
    
    var def3: String = ""
    var def2: String = ""
    var def1: String = ""
    var definitionArray = [""]
    var randomIndex1 = 0
    var randomIndex2 = 0
    var randomIndex3 = 0
    
    var randomNumber = 0
    
    
   
    
    var toDoWords: Results<Word>?
    var wordPool: Results<Word>?
//    var correctWord = ""
   
    var chosenCategory : Category? {
        didSet{
            loadWords()
          
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
      updateDisplay()
         randomNumber = Int(arc4random_uniform(3))
    
    }
   
    
    func loadWords(){
        toDoWords = chosenCategory?.words.sorted(byKeyPath: "title", ascending: true)
    }
    
    
    func updateDisplay() {
       
     
        
        //Picking 3 random (and not repeating)word definitions to display
        if let count = toDoWords?.count{
    randomIndex1 = Int(arc4random_uniform(UInt32(count)))
            randomIndex2 = Int(arc4random_uniform(UInt32(count)))
           randomIndex3 = Int(arc4random_uniform(UInt32(count)))
        repeat {
            randomIndex2 = Int(arc4random_uniform(UInt32(count)))
        } while randomIndex2 == randomIndex1 || randomIndex2 == randomIndex3
        repeat {
            randomIndex3 = Int(arc4random_uniform(UInt32(count)))
        } while randomIndex3 == randomIndex2 || randomIndex3 == randomIndex1
            
        
        
        let quizWord1 = toDoWords?[randomIndex1]
    let quizWord2 = toDoWords?[randomIndex2]
    let quizWord3 = toDoWords?[randomIndex3]
            
            
            quizWordLabel.text = quizWord1?.title
   
            getDefinition(word: (quizWord1?.title)!)
            getDefinition(word: (quizWord2?.title)!)
            getDefinition(word: (quizWord3?.title)!)
           
            
       
        } else {print("Unable to fetch defintions")}}
    
    func getDefinition(word: String) {
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
                    self.parseDefinition(json: jsonData)
    } else {
                                    print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
                    print(response)
                    print(error)
                    DispatchQueue.main.sync {
                                   //             self.definitionField.text = "Not able to fetch definition. Check connection, and/or spelling!"
                    }}
            }).resume()
        }}

func parseDefinition(json : JSON) {
let definitionResult = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"]
    
    if let definitionAsString = definitionResult.rawString() {
        if def1 == "" {
            def1 = definitionAsString
        } else if def2 == "" {
            def2 = definitionAsString
        } else if def3 == "" {
            def3 = definitionAsString
        }
       
        
        
        if randomNumber == 0 {
        DispatchQueue.main.sync {
option1.setTitle(def1, for: .normal)
                option2.setTitle(def2, for: .normal)
            option3.setTitle(def3, for: .normal)}
            
            } else if randomNumber == 1 {
            DispatchQueue.main.sync {
                option1.setTitle(def3, for: .normal)
                option2.setTitle(def1, for: .normal)
                option3.setTitle(def2, for: .normal)}
            
            } else if randomNumber == 2 {
            DispatchQueue.main.sync {
                option1.setTitle(def2, for: .normal)
                option2.setTitle(def3, for: .normal)
                option3.setTitle(def1, for: .normal)
            }}
print(definitionAsString)
        }

    
        
    
    
    
    }


    
   @IBOutlet weak var option1: UIButton!
    
    @IBOutlet weak var option2: UIButton!
    
    @IBOutlet weak var option3: UIButton!




}
