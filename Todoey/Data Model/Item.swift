//
//  Item.swift
//  Todoey
//
//  Created by Levi Yoder on 4/19/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var dateCreated: Date?
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
