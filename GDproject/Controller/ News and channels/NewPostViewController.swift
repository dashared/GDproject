//
//  NewPostViewController.swift
//  GDproject
//
//  Created by cstore on 05/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import Cartography
import Marklight
import TinyConstraints
import WSTagsField

class NewPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var viewForTags: UIView!
    
    fileprivate let tagsField = WSTagsField()
    // Keep strong instance of the `NSTextStorage` subclass
    let textStorage = MarklightTextStorage()
    
    weak var parentVC: NewsController?
    var myProtocol: NewPostDelegate?
    
    static var draft: String = ""
    static var hashTagsDraft: [String] = []
    
    var textView: UITextView!
    
    // buttons for attaching images
    var accessoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var addEquasion: UIButton = {
        var button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(addMathBrackets), for: .touchUpInside)
        return button
    }()
    
    // stack view where buttons will be places
    var stackAccessoryView: UIStackView?
    // Connect the view1's bottom layout constraint to react to keyboard movements
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //createTimerForUpdates()
        
        setUpMD()
        setUpTextView()
        setUpAccessoryView()
        setUpTagsView()
    }

    func setUpTagsView(){
        tagsField.frame = viewForTags.bounds
        viewForTags.addSubview(tagsField)
        
        // tagsField.translatesAutoresizingMaskIntoConstraints = false
        // tagsField.heightAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        
        tagsField.cornerRadius = 3.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10
        
        //tagsField.numberOfLines = 3
        //tagsField.maxHeight = 100.0
        
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //old padding
        
        tagsField.placeholder = "Enter a tag"
        tagsField.placeholderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        tagsField.returnKeyType = .next
        tagsField.delimiter = ""
        
        tagsField.textDelegate = self
        tagsField.acceptTagOption = .space
        
        textFieldEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "New post"
        textView.text = NewPostViewController.draft
        tagsField.addTags(NewPostViewController.hashTagsDraft)

    }
    
    func setUpAccessoryView(){
        let views = [UIButton(type: .contactAdd),addEquasion]
        stackAccessoryView = UIStackView(arrangedSubviews: views)
        
        stackAccessoryView?.alignment = .fill
        stackAccessoryView?.distribution = .equalSpacing
        
        view1.addSubview(accessoryView)
        accessoryView.addSubview(stackAccessoryView!)
        accessoryView.height(40)
        
        let separatorView = UIView()
        separatorView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        accessoryView.addSubview(separatorView)
        separatorView.height(1)
        separatorView.edgesToSuperview(excluding: .bottom)
        
        accessoryView.edgesToSuperview(excluding: [.top])
        stackAccessoryView!.edgesToSuperview(insets: .left(16) + .right(16) + .top(1))
    }
    
    func setUpTextView(){
        view.addConstraint(bottomTextViewConstraint)
        view1.addSubview(textView)
        textView.edgesToSuperview(insets: .top(8) + .left(8) + .bottom(40+8) + .right(8))
        
        if #available(iOS 11.0, *) {
            textView.smartDashesType = .no
            textView.smartQuotesType = .no
        }
        
        textView.isScrollEnabled = true
        
        guard let bottomTextViewConstraint = bottomTextViewConstraint else { return }
        view.addConstraint(bottomTextViewConstraint)
        
        // Add a beautiful padding to the `UITextView` content
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        textView.delegate = self
        magicForKeyboardChanges()
    }
    
    
    func magicForKeyboardChanges()
    {
        /////////////////////////////
        // We do some magic to resize the `UITextView` to react the the keyboard size change (appearance, disappearance, ecc)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Partial fixes to a long standing bug, to keep the caret inside the `UITextView` always visible
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: textView, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            if self!.textView.textStorage.string.hasSuffix("\n") {
                CATransaction.setCompletionBlock({ () -> Void in
                    self!.scrollToCaret(self!.textView, animated: false)
                })
            } else {
                self!.scrollToCaret(self!.textView, animated: false)
            }
        }
        
    }
    
    @objc func handleKeyboardNotifications(notification: NSNotification){
        if let userInfo = notification.userInfo{
            // UIKeyboardFrameEndUserInfoKey
            
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            bottomTextViewConstraint?.constant = notification.name == UIResponder.keyboardWillShowNotification ? keyBoardFrame.height - tabBarController!.tabBar.frame.height : 0
            
            print(bottomTextViewConstraint!.constant)
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                
            }
        }
    }
    
    @objc func attachPhoto(){
        
    }
    
    
    @objc func addMathBrackets()
    {
       // nothing
    }
    
    func setUpMD(){
        textStorage.marklightTextProcessor.codeColor = UIColor.orange
        textStorage.marklightTextProcessor.quoteColor = UIColor.darkGray
        textStorage.marklightTextProcessor.syntaxColor = UIColor.blue
        textStorage.marklightTextProcessor.codeFontName = "Courier"
        textStorage.marklightTextProcessor.fontTextStyle = UIFont.TextStyle.subheadline.rawValue
        textStorage.marklightTextProcessor.hideSyntax = false
        
        let layoutManager = NSLayoutManager()
        
        // Assign the `UITextView`'s `NSLayoutManager` to the `NSTextStorage` subclass
        //textStorage.addLayoutManager(textView.layoutManager)
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: view.bounds, textContainer: textContainer)
    }
    
    var indexOfPost = 0
    // MARK:- new post
    @objc func newPost(){
        Model.createAndPublish(body: [Model.Attachments(markdown: textView!.text)], tags: tagsField.tags.map { $0.text })
        // adding row to uiTableView after adding new post
        // myProtocol?.addPost(post: p)
        moveBackToParentVC()
        // somewhere here i will be sending server notifications about new post arrival
    }
    
    @objc func actionSaveDraft(){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save draft", style: .default)
        {
            [weak self]
            _ in
            NewPostViewController.draft = self?.textView.text ?? ""
            NewPostViewController.hashTagsDraft = self?.tagsField.tags.map { $0.text } ?? []
            self?.moveBackToParentVC()
        }
        
        let deleteAction = UIAlertAction(title: "Delete draft", style: .destructive)
        {
            [weak self] (_)
            in
            NewPostViewController.draft = ""
            NewPostViewController.hashTagsDraft = []
            self?.moveBackToParentVC()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func closeView()
    {
        actionSaveDraft()
    }
    
    func moveBackToParentVC(){
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
        textView!.resignFirstResponder()
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("Should interact with: \(URL)")
        return true
    }
    
    func scrollToCaret(_ textView: UITextView, animated: Bool) {
        var rect = textView.caretRect(for: textView.selectedTextRange!.end)
        rect.size.height = rect.size.height + textView.textContainerInset.bottom
        textView.scrollRectToVisible(rect, animated: animated)
    }
    
    fileprivate func textFieldEvents() {
        tagsField.onDidAddTag = { _, _ in
            print("onDidAddTag")
        }
        
        tagsField.onDidRemoveTag = { _, _ in
            print("onDidRemoveTag")
        }
        
        tagsField.onDidChangeText = { _, text in
            print("onDidChangeText")
        }
        
        tagsField.onDidChangeHeightTo = { _, height in
            print("HeightTo \(height)")
        }
        
        tagsField.onDidSelectTagView = { _, tagView in
            print("Select \(tagView)")
        }
        
        tagsField.onDidUnselectTagView = { _, tagView in
            print("Unselect \(tagView)")
        }
    }
}


extension NewPostViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagsField {
            textView.becomeFirstResponder()
        }
        return true
    }
    
}
