//
//  AppDelegate.swift
//  Todoey
//
//  Created by Levi Yoder on 4/9/18.
//  Copyright © 2018 Levi Yoder. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        do {
            _ = try Realm()
            }
         catch {
            print("Error initializing new realm \(error)")
        }
        
        return true
    }


}

