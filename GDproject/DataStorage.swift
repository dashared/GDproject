//
//  DataStorage.swift
//  GDproject
//
//  Created by cstore on 21/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation

/**
 _DataStorage_ class is aimed to store user private settings
 to display correct data after user leaving the app
 */
class DataStorage{
    
    private init(){}
    
    static let standard = DataStorage()
    
    // add channel
    
    // delete channel
    
    /**
      Function for setting log in status of user
     */
    func setIsLoggedIn(value: Bool){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.loggedIn.rawValue)
    }
    
    /**
     Function to determine is user logged in already or not
    */
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue)
    }
}

/**
 Enum to store UserDefaults keys for getting and setting values
 */
enum UserDefaultsKeys: String{
    case loggedIn
}
