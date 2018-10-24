//
//  Item.swift
//  Todoey
//
//  Created by Levi Yoder on 4/19/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import Foundation
import RealmSwift

class Word: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var dateCreated: Date?
    @objc dynamic var timesCorrect: Int = 0
    @objc dynamic var definition: String = ""
  @objc dynamic var category: String = ""
    @objc dynamic var hasBeenQuizzed : Bool = false
    @objc dynamic var isBeingQuizzed : Bool = false
    @objc dynamic var gottenWrong : Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "words")
    
}
