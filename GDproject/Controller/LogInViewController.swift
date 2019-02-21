//
//  LogInViewController.swift
//  NewsFeed
//
//  Created by cstore on 20/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    
    static let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 0.5)
    
    var bottomConstraint: NSLayoutConstraint?
    
    let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font  = UIFont.boldSystemFont(ofSize: 16)
        button.isEnabled = false
        button.addTarget(self, action: #selector(activateLogInProcess), for: .touchUpInside)
        return button
    }()
    
    let keyboardBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureTapgesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // MARK:- uncomment when mail registration will be availiable
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // MARK:- uncomment when mail registration will be availiable
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureTapgesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    @objc func activateLogInProcess(){
        if logInButton.isEnabled {
            // MARK:- when log in is succeeded do I need to go there?
            let vc = storyboard!.instantiateViewController(withIdentifier: newsController) as! NewsController
            present(vc, animated: true) {
                print("logged in")
            }
            DataStorage.standard.setIsLoggedIn(value: true)
            view.endEditing(true)
        }
    }
    
    func setUpView(){
        mailTextField.delegate = self
        view.addSubview(keyboardBar)
        
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: keyboardBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]", views: keyboardBar)
        
        setUpBarComponents()
        
        bottomConstraint = NSLayoutConstraint(item: keyboardBar, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        // for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // for log in button notifications
        NotificationCenter.default.addObserver(self, selector: #selector(inputDidChanged), name: UITextField.textDidChangeNotification, object: mailTextField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputDidChanged), name: UITextField.textDidBeginEditingNotification, object: mailTextField)
    }
    
    @objc func inputDidChanged(notification: NSNotification){
        if mailTextField.text?.isEmpty ?? true
        {
            logInButton.isEnabled = false
            logInButton.setTitleColor(LogInViewController.titleColor.withAlphaComponent(0.5), for: .normal)
        }
        else
        {
            logInButton.isEnabled = true
            logInButton.setTitleColor(LogInViewController.titleColor.withAlphaComponent(1), for: .normal)
        }
    }
    
    @objc func handleKeyboardNotifications(notification: NSNotification){
        if let userInfo = notification.userInfo{
            // UIKeyboardFrameEndUserInfoKey
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            bottomConstraint?.constant = notification.name == UIResponder.keyboardWillShowNotification ? -keyBoardFrame.height+view.safeAreaInsets.bottom : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                
            }
        }
    }
    
    func setUpBarComponents(){
        keyboardBar.addSubview(logInButton)
        keyboardBar.addConstraintsWithFormat(format: "H:[v0(60)]-16-|", views: logInButton)
        keyboardBar.addConstraintsWithFormat(format: "V:|[v0]|", views: logInButton)
    }
}


extension LogInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
