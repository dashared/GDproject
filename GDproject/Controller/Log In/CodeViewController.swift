//
//  CodeViewController.swift
//  GDproject
//
//  Created by cstore on 10/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class CodeViewController: UIViewController {

    @IBOutlet weak var f1: UITextField!
    @IBOutlet weak var f2: UITextField!
    @IBOutlet weak var f3: UITextField!
    @IBOutlet weak var f4: UITextField!
    @IBOutlet weak var f5: UITextField!
    @IBOutlet weak var f6: UITextField!
    
    var onSuccessLogIn: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
        
        f1.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
        f2.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
        f3.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
        f4.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
        f5.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
        f6.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        f1.becomeFirstResponder()
    }
    
    @objc func textFiledDidChange(textField: UITextField) {
        let text = textField.text
        
        // only 1 char
        if text?.utf16.count == 1 {
            switch textField {
            case f1:
                f2.becomeFirstResponder()
            case f2:
                f3.becomeFirstResponder()
            case f3:
                f4.becomeFirstResponder()
            case f4:
                f5.becomeFirstResponder()
            case f5:
                f6.becomeFirstResponder()
            case f6:
                f6.resignFirstResponder()
            default:
                break
            }
        }
    }
    
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func whereToGoNext(_ sender: UIButton)
    {
        let code = "\(f1.text!)\(f2.text!)\(f3.text!)\(f4.text!)\(f5.text!)\(f6.text!)"
        if let codeToInt = Int(code)
        {
            Model.verify(with: codeToInt) { _ in
                // if everything is okay we can authemticicate
                // Model.authemticiateMe
                Model.authenticateMe { [weak self] (res) in
                    if res {
                        self?.onSuccessLogIn?()
                    } else {
                        print("sosi")
                    }
                }
            }
        }
    }
    
    func setUpConstraint(){
        // for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotifications(notification: NSNotification){
        if let userInfo = notification.userInfo {
            // UIKeyboardFrameEndUserInfoKey
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            bottomConstraint.constant = notification.name == UIResponder.keyboardWillShowNotification ? keyBoardFrame.height - self.view.safeAreaInsets.bottom : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

}
