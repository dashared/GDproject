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
    
    var cookie: HTTPCookie? = nil {
        didSet {
            (UIApplication.shared.delegate as? AppDelegate)?.tabCoordinator.start()
        }
    }
    // add channel
    
    // delete channel
    
    /**
      Function for setting log in status of user
     */
    func setIsLoggedIn(value: Bool){
        UserDefaults.standard.set(value, forKey: UserDefaultsKeys.loggedIn.rawValue)
        if !value {
            (UIApplication.shared.delegate as? AppDelegate)?.logInAgain()
        }
    }
    
    /**
     Function to determine is user logged in already or not
    */
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn.rawValue) && cookie != nil
    }
}

/**
 Enum to store UserDefaults keys for getting and setting values
 */
enum UserDefaultsKeys: String{
    case loggedIn
    case cookie
}
