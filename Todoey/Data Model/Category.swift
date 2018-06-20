//
//  Category.swift
//  Todoey
//
//  Created by Levi Yoder on 4/19/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
let words = List<Word>()
}
