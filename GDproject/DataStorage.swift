//
//  DataStorage.swift
//  GDproject
//
//  Created by cstore on 21/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

/**
 _DataStorage_ class is aimed to store user private settings
 to display correct data after user leaving the app
 */
class DataStorage{
    
    private init(){}
    
    //weak var coordinator: LogInCoordinator?
    static let standard = DataStorage()
    
    /**
      Function for setting log in status of user
     */
    func setIsLoggedIn(value: Bool, with id: Int){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.loggedIn.rawValue)
        setUserKey(with: id)
        isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue)
    }
    
    func setUserKey(with id: Int){
        UserDefaults.standard.set(id, forKey: UserDefaultsKeys.id.rawValue)
    }
    
    func getUserId() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.id.rawValue)
    }
    
    func setEmail(email: String) {
        UserDefaults.standard.set(email, forKey: UserDefaultsKeys.email.rawValue)
    }
    
    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.email.rawValue)
    }
    /**
     Function to determine is user logged in already or not
    */
    var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue)
}

/**
 Enum to store UserDefaults keys for getting and setting values
 */
enum UserDefaultsKeys: String{
    case loggedIn
    case id
    case email
}
