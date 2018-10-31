//
//  FlashCardViewController.swift
//  Dictionary Flash
//
//  Created by Levi Yoder on 10/25/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import AVFoundation

class FlashCardViewController : UIViewController {

    @IBOutlet weak var definitionField: UITextView!

    @IBOutlet weak var wordTitleLabel: UILabel!

    var chosenWord = Word()


override func viewDidLoad() {
    if chosenWord.definition == "" {
        hitAPI(wordToFind: chosenWord)
    } else {
        wordTitleLabel.text = chosenWord.title
        definitionField.text = chosenWord.definition
    }}


func hitAPI(wordToFind : Word){
     let wordTitle = wordToFind.title
        let appId = "219ad5f4"
        let appKey = "6e3ee9bd554aecdf493aebe931043b6b"
        let language = "en"
        
        let stringURL =  "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(wordTitle)"
        if let encoded = stringURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let myURL = URL(string: encoded) {
            print(myURL)
            var request = URLRequest(url: myURL)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(appId, forHTTPHeaderField: "app_id")
            request.addValue(appKey, forHTTPHeaderField: "app_key")
            
            let session = URLSession.shared
            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                if let response = response,
                    let data = data,
                    let jsonData = try? JSON(JSONSerialization.jsonObject(with: data, options: .mutableContainers)) {
                    
                    //                        self.parseDefinition(wordToSaveTo: word, word1: word1, word2: word2, word3: word3, json: jsonData, randomIndex: randomIndex)
                    //
                    print(jsonData)
                    print(response)
                    self.parseDefinition(wordToSaveTo: wordToFind, json: jsonData)
                } else {
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("REPONSE STATUS CODE IS \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 404 {
                            DispatchQueue.main.async {
                                do{
                                    try realm.write {
                                        wordToFind.definition = "Can't find a definition for '\(wordTitle)'. Check spelling!"
                                    }
                                } catch {
                                    print("error saving 404 error to word definition")
                                }
                            }}
                        
                        
                    }
                    
                    print("response is \(response)")
                    print("error is \(error)")
                    
                    
        DispatchQueue.main.sync {
            self.definitionField.text = "Not able to fetch definition. Check connection, and/or spelling!"
        }
                    
                }
            }).resume()
        }
}
    
    
    
    func parseDefinition(wordToSaveTo: Word, json : JSON) {
        let definitionResult = json["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"]
       let audioURL = json["results"][0]["lexicalEntries"][0]["pronunciations"][0]["audioFile"]
        DispatchQueue.main.sync {
            if let definitionAsString = definitionResult.rawString() {
                print("definitionasString is \(definitionAsString)")
                //        print("definition as string: \(definitionAsString)")
                let delCharSet1 = NSCharacterSet(charactersIn: "[   \"")
                let partiallyEditedDefinition = definitionAsString.trimmingCharacters(in: delCharSet1 as CharacterSet)
                //        print("edited definition: \(partiallyEditedDefinition)")
                let delCharSet2 = NSCharacterSet(charactersIn: "\"   ]")
                let fullyEditedDefinition = partiallyEditedDefinition.trimmingCharacters(in: delCharSet2 as CharacterSet)
             
                
                do{
                    try realm.write {
                        wordToSaveTo.definition = fullyEditedDefinition
                    }
                } catch {
                    print("error saving definition to realm file\(error)")
                }}
            
            if let audioUrlAsString = audioURL.rawString() {
                print(audioUrlAsString)
                
                do{
                    try realm.write {
                        wordToSaveTo.pronunciationURL = audioUrlAsString
                    }
                } catch {
                    print("error saving audioURL to realm file\(error)")
                }
                wordTitleLabel.text = chosenWord.title
                definitionField.text = chosenWord.definition
            }
        
        }
        }
    func play(url:String) {
        var player: AVPlayer!
        if let url1  = URL.init(string: url){
        print(url1)
        let playerItem: AVPlayerItem = AVPlayerItem(url: url1)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player!)
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer)
        player.play()
        }
}
    
    @IBAction func hearPronunciationPressed(_ sender: UIBarButtonItem) {
        play(url: chosenWord.pronunciationURL)
    }
    
}



