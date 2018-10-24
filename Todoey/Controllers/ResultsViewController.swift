//
//  ResultsViewController.swift
//  Dictionary Flash
//
//  Created by Levi Yoder on 9/6/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift


class ResultsViewController: UIViewController {
 
    var wrongWordsCount = 0
    var totalWordsCount = 0
    var categoryName = ""
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let wordsGottenWrongPredicate = NSPredicate(format:"category = %@ AND gottenWrong == %@", categoryName, NSNumber(value: true))
        let wordsGottenWrong = realm.objects(Word.self).filter(wordsGottenWrongPredicate)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
    
    navigationItem.leftBarButtonItem = backButton
    
    wrongWordsCount = wordsGottenWrong.count
    scoreLabel.text = "\(wrongWordsCount) of \(totalWordsCount)"
   
        if wrongWordsCount == 0 {
            wrongWordsLabel.text = "Good job, you got all of the definitions correct!"
        }
        
        
     else if wrongWordsCount > 0 {
        var adjustedCount = wrongWordsCount - 1
        var wordDef = "\(wordsGottenWrong[adjustedCount].title): \(wordsGottenWrong[adjustedCount].definition)"

        repeat {
           adjustedCount = adjustedCount - 1
            wordDef = wordDef + "\n \(wordsGottenWrong[adjustedCount].title): \(wordsGottenWrong[adjustedCount].definition)"
           
             } while adjustedCount > 0
        
        
        wrongWordsLabel.text = wordDef
        print(wordDef)
        
        //        repeat {
//            statements
//        } while condition
        
        
        
        
        
        
    }
    
    
    
    
//    wrongWordsLabel = wordsGottenWrong
//    print(wordsGottenWrong)
    
    }


    @IBAction func doneButtonPressed(_ sender: Any) {
    self.performSegue(withIdentifier: "UnwindToCategoryVC", sender: self)
    }
    
    //MARK: - IBOUTLETS/IBACTIONS
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var wrongWordsLabel: UILabel!
    
}
