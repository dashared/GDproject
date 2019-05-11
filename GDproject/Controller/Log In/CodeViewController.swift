//
//  CodeViewController.swift
//  GDproject
//
//  Created by cstore on 10/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class CodeViewController: UIViewController {

    @IBOutlet weak var f1: UITextField!
    @IBOutlet weak var f2: UITextField!
    @IBOutlet weak var f3: UITextField!
    @IBOutlet weak var f4: UITextField!
    @IBOutlet weak var f5: UITextField!
    @IBOutlet weak var f6: UITextField!
    
    var loading = UIActivityIndicatorView(style: .gray)
    
    var onSuccessLogIn: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraint()
        
        navigationItem.title = DataStorage.standard.getEmail()
        
        f1.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
        f2.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
        f3.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
        f4.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
        f5.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
        f6.addTarget(self, action: #selector(textFiledDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        loading.stopAnimating()
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
    
    
    func presentAlertInvalidData(with text: String)
    {
        let alert = UIAlertController(title: "Invalid code", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        loading.stopAnimating()
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func whereToGoNext(_ sender: UIButton)
    {
        guard let f1t = f1.text, let f2t = f2.text, let f3t = f3.text, let f4t = f4.text, let f5t = f5.text, let f6t = f6.text else {
            presentAlertInvalidData(with: "Some fields are missing");
            return
        }
        
        if f1t.isEmpty || f2t.isEmpty || f3t.isEmpty || f4t.isEmpty || f5t.isEmpty || f6t.isEmpty {
            presentAlertInvalidData(with: "Some fields are missing");
            return
        }
        
        let code = "\(f1.text!)\(f2.text!)\(f3.text!)\(f4.text!)\(f5.text!)\(f6.text!)"
        if let codeToInt = Int(code)
        {
            loading.startAnimating()
            Model.verify(with: codeToInt) { [weak self] in
                // if everything is okay we can authemticicate
                if !$0 {
                    self?.presentAlertInvalidData(with: "Wrong code. Try again!")
                    self?.loading.stopAnimating()
                    return
                } else {
                    // Model.authemticiateMe
                    Model.authenticateMe { [weak self] (res) in
                        if res {
                            self?.onSuccessLogIn?()
                        }
                    }
                    return
                }
            }
        }
    }
    
    func setUpConstraint()
    {
        self.view.addSubview(loading)
        loading.centerInSuperview()
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
