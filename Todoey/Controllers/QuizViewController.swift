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
    var randomIndex1 = 0
    var randomIndex2 = 0
    var randomIndex3 = 0
    var quizWord1 = Word()
    var quizWord2 = Word()
    var quizWord3 = Word()
    var correctCount = 0
    var wrongCount = 0
    var numberQuizzed = 1
   var totalWordsCount = 0
    var categoryName = ""
    var randomNumber = 0
    var chosenCategory : Category? {
        didSet{
            categoryName = (chosenCategory?.name)!
        resetBools()
            
        }
    }
    
    var wordsGottenWrong = realm.objects(Word.self)
    var correctWordPool = realm.objects(Word.self)
var wrongWordPool = realm.objects(Word.self)

    //    var myColor = UIColor(red:0.96, green:0.28, blue:0.28, alpha:1.0)
  
    var lightestTeal = UIColor(red: 0.6157, green: 0.9529, blue: 0.7686, alpha: 1)
    var mediumTeal = UIColor(red: 0.3843, green: 0.8235, blue: 0.6353, alpha: 1)
    var darkestTeal = UIColor(red: 0.1216, green: 0.6706, blue: 0.5373, alpha: 1)
  
    override func viewDidLoad() {
        resetBools()
        super.viewDidLoad()
        option1.layer.borderWidth = 1.25
        option2.layer.borderWidth = 1.25
        option3.layer.borderWidth = 1.25
        
        option1.layer.borderColor = UIColor.white.cgColor
        option2.layer.borderColor = UIColor.white.cgColor
        option3.layer.borderColor = UIColor.white.cgColor
        
        updateDisplay()
    
        self.navigationController?.navigationBar.tintColor = UIColor.white;

        progressTracker.title = "\(numberQuizzed)/\(totalWordsCount)"
    }
   

    
    
    func updateDisplay() {
     randomNumber = Int(arc4random_uniform(3))
 
        let totalWordsPredicate = NSPredicate(format: "category = %@", categoryName)
       
       let totalWords = realm.objects(Word.self).filter(totalWordsPredicate)
        totalWordsCount = totalWords.count
        
        let predicate = NSPredicate(format: "category = %@ AND hasBeenQuizzed == %@", categoryName, NSNumber(value: false))
        let wrongPredicate = NSPredicate(format: "category = %@ AND isBeingQuizzed == %@", categoryName, NSNumber(value: false))
        
        correctWordPool = realm.objects(Word.self).filter(predicate).sorted(byKeyPath: "title", ascending: true)
        wrongWordPool = realm.objects(Word.self).filter(wrongPredicate).sorted(byKeyPath: "title", ascending: true)
        
        //Picking 3 random (and not repeating)word definitions to display
    correctCount = (correctWordPool.count) - 1
  wrongCount = (wrongWordPool.count) - 1
//        print("word pool count is \(correctCount)")
  
        (randomIndex1, randomIndex2, randomIndex3) = self.assignRandomIndex(correctCount: correctCount, wrongCount: wrongCount)
//        print("update display random index 1 is \(randomIndex1)")
//     print("update display random index 2 is \(randomIndex2)")
//        print("update display random index 3 is \(randomIndex3)")
        
 (quizWord1, quizWord2, quizWord3) = self.getQuizWords(randomIndex1: randomIndex1, randomIndex2: randomIndex2, randomIndex3: randomIndex3)
    
            self.quizWordLabel.text = quizWord1.title

        if quizWord1.definition == "" {
            self.getDefinition(defToFetch: quizWord1, word1: quizWord1, word2: quizWord2, word3: quizWord3, wordTitle: (quizWord1.title), randomIndex: randomIndex1)}
           
            if quizWord2.definition == "" {
                self.getDefinition(defToFetch: quizWord2, word1: quizWord1, word2: quizWord2, word3: quizWord3, wordTitle: (quizWord2.title), randomIndex: randomIndex2)}
       
            if quizWord3.definition == "" {
                self.getDefinition(defToFetch: quizWord3, word1: quizWord1, word2: quizWord2, word3: quizWord3, wordTitle: (quizWord3.title), randomIndex: randomIndex3)}
    
        if quizWord1.definition != "" && quizWord2.definition != "" && quizWord3.definition != "" {
            setTitles(word1: quizWord1, word2: quizWord2, word3: quizWord3)}
        
        }
    
    func getDefinition(defToFetch: Word, word1: Word, word2: Word, word3: Word, wordTitle: String, randomIndex: Int) {
        let word = defToFetch
        let word1 = word1
        let word2 = word2
        let word3 = word3
        let appId = "219ad5f4"
        let appKey = "6e3ee9bd554aecdf493aebe931043b6b"
        let language = "en"
    if let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(wordTitle)"){
        
            
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
                    self.parseDefinition(wordToSaveTo: word, word1: word1, word2: word2, word3: word3, json: jsonData, randomIndex: randomIndex)
                
                    
                   
                    
                } else {
                    
                        if let httpResponse = response as? HTTPURLResponse {
                            print("REPONSE STATUS CODE IS \(httpResponse.statusCode)")
                            if httpResponse.statusCode == 404 {
                                DispatchQueue.main.async {
                                    do{
                                    try realm.write {
                                    defToFetch.definition = "Can't find a definition for '\(defToFetch.title)'. Check spelling!"
                                    }
                                    } catch {
                                    print("error saving 404 error to word definition")
                                }
                                }}
                            
                            
                            DispatchQueue.main.sync {
                                self.setTitles(word1: word1, word2: word2, word3: word3)
                            }
                    
                    }
                    
                    print("response is \(response)")
                    print("error is \(error)")
//                    DispatchQueue.main.sync {
//                                                self.definitionField.text = "Not able to fetch definition. Check connection, and/or spelling!"
//                    }
                    
                }
            }).resume()
        }}

    func parseDefinition(wordToSaveTo: Word, word1: Word, word2: Word, word3: Word, json : JSON, randomIndex : Int) {
let definitionResult = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"]
  DispatchQueue.main.sync {
    if let definitionAsString = definitionResult.rawString() {
print("definitionasString is \(definitionAsString)")
//        print("definition as string: \(definitionAsString)")
        let delCharSet1 = NSCharacterSet(charactersIn: "[   \"")
        let partiallyEditedDefinition = definitionAsString.trimmingCharacters(in: delCharSet1 as CharacterSet)
//        print("edited definition: \(partiallyEditedDefinition)")
        let delCharSet2 = NSCharacterSet(charactersIn: "\"   ]")
        let fullyEditedDefinition = partiallyEditedDefinition.trimmingCharacters(in: delCharSet2 as CharacterSet)
//        print("fully edited definition: \(fullyEditedDefinition)")

      
//        if definitionAsString = ! {
//
//        }
    
        do{
            try realm.write {
                wordToSaveTo.definition = fullyEditedDefinition
               }
        } catch {
            print("error saving definition to realm file\(error)")
        }}
    setTitles(word1: word1, word2: word2, word3: word3)
        }

    
        
    
    
    
    }
    func setTitles(word1: Word, word2: Word, word3: Word) {
       
     
        if randomNumber == 0 {
            
                option1.setTitle(word1.definition, for: .normal)
                option2.setTitle(word2.definition, for: .normal)
                option3.setTitle(word3.definition, for: .normal)
            
        } else if randomNumber == 1 {
            
                option1.setTitle(word3.definition, for: .normal)
                option2.setTitle(word1.definition, for: .normal)
                option3.setTitle(word2.definition, for: .normal)
            
        } else if randomNumber == 2 {
            
                option1.setTitle(word2.definition, for: .normal)
                option2.setTitle(word3.definition, for: .normal)
                option3.setTitle(word1.definition, for: .normal)
            }
    
    }
    
    func resetBools(){
       let predicate = NSPredicate(format: "category = %@", categoryName)
        do {
            try realm.write {
            let words = realm.objects(Word.self).filter(predicate)
            words.setValue(false, forKey: "hasBeenQuizzed")
            words.setValue(false, forKey: "isBeingQuizzed")
            words.setValue(false, forKey: "gottenWrong")
            }} catch{
                print("unable to update hasBeenQuizzed\(error)")
        }
    }
    
    
    
    func assignRandomIndex(correctCount: Int, wrongCount: Int) -> (Int, Int, Int) {
       
        randomIndex1 = Int(arc4random_uniform(UInt32(correctCount)))
        randomIndex2 = Int(arc4random_uniform(UInt32(wrongCount)))
        randomIndex3 = Int(arc4random_uniform(UInt32(wrongCount)))
      
        repeat {
            randomIndex3 = Int(arc4random_uniform(UInt32(wrongCount)))
        } while randomIndex3 == randomIndex2
//        print("assignRandomIndex randomindex1 is \(randomIndex1)")
//        print("assignRandomIndex randomindex2 is \(randomIndex2)")
//        print("assignRandomIndex randomindex3 is \(randomIndex3)")
    return ( randomIndex1, randomIndex2, randomIndex3)
    }
    
    func getQuizWords(randomIndex1: Int, randomIndex2: Int, randomIndex3: Int)-> (Word, Word, Word){
        let quizWord1 = correctWordPool[randomIndex1]
        do{
            try realm.write {
                quizWord1.isBeingQuizzed = true
            }
        } catch {
            print("error saving isBeingQuizzed to realm \(error)")
        }
        
        
        let quizWord2 = wrongWordPool[randomIndex2]
        let quizWord3 = wrongWordPool[randomIndex3]
        
        
        
        return (quizWord1, quizWord2, quizWord3)
        
        
    }

    func resetLabelFormats(){
        
    }
    
    
    //buttons have been pressed!
    
    @IBAction func option1pressed(_ sender: UIButton) {
       do{
            try realm.write {
                quizWord1.hasBeenQuizzed = true
            quizWord1.isBeingQuizzed = false
            }
        } catch {
           print("error saving hasBeenQuizzed to realm \(error)")
        }
        
        option2.isEnabled = false
        option1.isEnabled = false
        option3.isEnabled = false
        
       
        if randomNumber == 0{
            option1.setTitle("Correct!", for: .normal)
            option1.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option1.setTitleColor(darkestTeal, for: .normal)
            option1.backgroundColor = UIColor.clear
//            button.setTitle("my text here", for: .normal)
        } else {
            appendWrongWords(word: quizWord1)
            option1.setTitle("Incorrect!", for: .normal)
            option1.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option1.setTitleColor(darkestTeal, for: .normal)
            option1.backgroundColor = UIColor.clear
        }
        UIView.transition(with: option1,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.option1.isHighlighted = true },
                          completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.option1.setTitle("", for: .normal)
            self.option1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.option1.setTitleColor(UIColor.white, for: .normal)
            self.option1.backgroundColor = self.darkestTeal
            self.progressTracker.title = "\(self.numberQuizzed)/\(self.totalWordsCount)"
           
            //Determining if quiz is finished
            if self.numberQuizzed != self.totalWordsCount{
                self.numberQuizzed = (self.numberQuizzed) + 1
                self.updateDisplay()
                self.option2.isEnabled = true
                self.option1.isEnabled = true
                self.option3.isEnabled = true
                
            } else {
            self.performSegue(withIdentifier: "ResultsSegue", sender: self)
            }
            self.progressTracker.title = "\(self.numberQuizzed)/\(self.totalWordsCount)"
        }
        }
    
    @IBAction func option2pressed(_ sender: UIButton) {
    do{
            try realm.write {
                quizWord1.hasBeenQuizzed = true
            quizWord1.isBeingQuizzed = false
            }
        } catch {
            print("error saving hasBeenQuizzed to realm \(error)")
        }
       option1.isEnabled = false
        option2.isEnabled = false
        option3.isEnabled = false
        
        if randomNumber == 1{
            option2.setTitle("Correct!", for: .normal)
            option2.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option2.setTitleColor(darkestTeal, for: .normal)
            option2.backgroundColor = UIColor.clear
            //            button.setTitle("my text here", for: .normal)
        } else {
            appendWrongWords(word: quizWord1)

            option2.setTitle("Incorrect!", for: .normal)
            option2.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option2.setTitleColor(darkestTeal, for: .normal)
            option2.backgroundColor = UIColor.clear
        }
        UIView.transition(with: option2,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.option2.isHighlighted = true },
                          completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.option2.setTitle("", for: .normal)
            self.option2.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.option2.setTitleColor(UIColor.white, for: .normal)
            self.option2.backgroundColor = self.darkestTeal
            self.progressTracker.title = "\(self.numberQuizzed)/\(self.totalWordsCount)"
            //Determining if quiz is finished
            if self.numberQuizzed != self.totalWordsCount{
                self.numberQuizzed = (self.numberQuizzed) + 1
                self.updateDisplay()
                self.option2.isEnabled = true
                self.option1.isEnabled = true
                self.option3.isEnabled = true
            } else {
             self.performSegue(withIdentifier: "ResultsSegue", sender: self)
            }
            self.progressTracker.title = "\(self.numberQuizzed)/\(self.totalWordsCount)"
            
        }
       
    }
    
    @IBAction func option3pressed(_ sender: UIButton) {
        do{
            try realm.write {
                quizWord1.hasBeenQuizzed = true
           quizWord1.isBeingQuizzed = false
            }
        } catch {
            print("error saving hasBeenQuizzed to realm \(error)")
        }
      option2.isEnabled = false
        option1.isEnabled = false
      option3.isEnabled = false
        
        if randomNumber == 2{
            option3.setTitle("Correct!", for: .normal)
            option3.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option3.setTitleColor(darkestTeal, for: .normal)
            option3.backgroundColor = UIColor.clear
            //            button.setTitle("my text here", for: .normal)
        } else {
            
            appendWrongWords(word: quizWord1)

            option3.setTitle("Incorrect!", for: .normal)
            option3.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 30.0)
            option3.setTitleColor(self.darkestTeal, for: .normal)
            option3.backgroundColor = UIColor.clear
        }
        UIView.transition(with: option3,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.option3.isHighlighted = true },
                          completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.option3.setTitle("", for: .normal)
            self.option3.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.option3.setTitleColor(UIColor.white, for: .normal)
            self.option3.backgroundColor = self.darkestTeal
            //Determining if quiz is finished
            if self.numberQuizzed != self.totalWordsCount{
                self.numberQuizzed = (self.numberQuizzed) + 1
                self.updateDisplay()
                self.option1.isEnabled = true
                self.option2.isEnabled = true
                self.option3.isEnabled = true
            } else {
           self.performSegue(withIdentifier: "ResultsSegue", sender: self)
            }
            self.progressTracker.title = "\(self.numberQuizzed)/\(self.totalWordsCount)"
           }
      
            
       
    }
 
  
    
    //MARK:- SEGUE TO RESULTS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ResultsViewController

     destinationVC.categoryName = categoryName
    destinationVC.totalWordsCount = totalWordsCount
    destinationVC.wrongWordsCount = wordsGottenWrong.count
    }
    
    
    //MARK: - APPEND WORDSGOTTENWRONG
    
    func appendWrongWords(word: Word) {
        do{
            try realm.write {
                word.gottenWrong = true
            }
        } catch {
            print("Error saving wordGottenWrong TRUE to realm.\(error)")
        }
        
        let wordsGottenWrongPredicate = NSPredicate(format:"category = %@ AND gottenWrong == %@", categoryName, NSNumber(value: true))
        wordsGottenWrong = realm.objects(Word.self).filter(wordsGottenWrongPredicate)
        
        print("WORDS GOTTEN WRONG COUNT IS \(wordsGottenWrong.count)")
    }
    
    //MARK:- IBOUTLETS
    
    @IBOutlet weak var option1: UIButton!
    
    @IBOutlet weak var option2: UIButton!
    
    @IBOutlet weak var option3: UIButton!

    @IBOutlet weak var quizWordLabel: UILabel!

    @IBOutlet weak var progressTracker: UIBarButtonItem!
    
    

}
