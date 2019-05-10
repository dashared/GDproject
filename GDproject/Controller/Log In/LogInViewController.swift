//
//  LogInViewController.swift
//  RxSwift
//
//  Created by cstore on 01/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints
import ReactiveSwift
import ReactiveCocoa
import Result

class LogInViewController: UIViewController {
    
    var authenticate: ((String)->())?
    
    let logInLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    let mailTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        textField.placeholder = "Mail"
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.clearButtonMode = .always
        return textField
    }()
    
    let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(blueSystemColor, for: .normal)
        button.titleLabel?.font  = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handleTap(){
        authenticate?(mailTextField.text!)
    }
    
    private lazy var keyboardBar = UIView()
    private lazy var contentView = UIView()
    private var bottomConstraint: NSLayoutConstraint?
    
    func setUpView(){
        // logIn stack with textField and label
        view.addSubview(contentView)
        contentView.edgesToSuperview(excluding: .bottom, insets: .left(16) + .right(16) + .top(80), usingSafeArea: true)
        let views = [logInLabel, mailTextField]
        contentView.stack(views, axis: .vertical, spacing: 10)
    }
    
    func configureKeyboard(){
        
        // configure keyboardBar setUp
        view.addSubview(keyboardBar)
        keyboardBar.height(50)
        keyboardBar.edgesToSuperview(excluding: [.top,.bottom])
        bottomConstraint = NSLayoutConstraint(item: keyboardBar, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        // configure keyboardBar components
        keyboardBar.addSubview(logInButton)
        logInButton.height(50)
        logInButton.rightToSuperview(view.rightAnchor, offset: 16, relation: .equal, isActive: true)
        
    }
    
    func logicOfLogInInputValidation() -> ((String?)->()) {
        
        let logic: ((String?)->()) = { [weak self] (someText) in
            if let text = someText, !text.isEmpty {
                self?.logInButton.isEnabled = true
            } else {
                self?.logInButton.isEnabled = false
            }
        }
        
        return logic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpView()
        configureKeyboard()
        
        let mailFieldValuesSignal: Signal<String, NoError> = mailTextField.reactive.continuousTextValues
        
        mailFieldValuesSignal.observeValues(logicOfLogInInputValidation())
        
        // for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func handleKeyboardNotifications(notification: NSNotification){
        if let userInfo = notification.userInfo{
            // UIKeyboardFrameEndUserInfoKey
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            bottomConstraint?.constant = notification.name == UIResponder.keyboardWillShowNotification ? -keyBoardFrame.height+view.safeAreaInsets.bottom : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

extension UIButton {
    override open var isEnabled: Bool {
        didSet {
            let color = isEnabled ? self.titleLabel?.textColor.withAlphaComponent(1) : self.titleLabel?.textColor.withAlphaComponent(0.5)
            self.setTitleColor(color, for: .normal)
        }
    }
}
