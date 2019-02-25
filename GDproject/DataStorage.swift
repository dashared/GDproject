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
    func setIsLoggedIn(value: Bool){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.loggedIn.rawValue)
        isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue)
    }
    
    func setUserKey(with id: Int){
        UserDefaults.standard.set(id, forKey: UserDefaultsKeys.id.rawValue)
    }
    
    func getUserId() -> Int?{
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.id.rawValue)
    }
    /**
     Function to determine is user logged in already or not
    */
    var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue) {
        didSet{
            if isLoggedIn {
                (UIApplication.shared.delegate as? AppDelegate)?.tabCoordinator.start()
            } else {
                (UIApplication.shared.delegate as? AppDelegate)?.logInAgain()
            }
        }
    }
}

/**
 Enum to store UserDefaults keys for getting and setting values
 */
enum UserDefaultsKeys: String{
    case loggedIn
    case id
}
