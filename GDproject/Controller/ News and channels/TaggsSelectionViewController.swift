//
//  TaggsSelectionViewController.swift
//  GDproject
//
//  Created by cstore on 03/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TaggerKit

protocol TagsReceiver: class {
    func receiveTags(tags: [String])
}

class TaggsSelectionViewController: UIViewController {

    @IBOutlet weak var addTagsTextField: TKTextField!
    
    @IBOutlet weak var searchContainerView: UIView!
    
    @IBOutlet weak var testContainer: UIView!
    
    // We want the whole experience, let's create two TKCollectionViews
    let productTags = TKCollectionView()
    let allTags     = TKCollectionView()
    
    var currentTags: [String]?
    weak var receiver: TagsReceiver?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Hashtags"
        addTagsTextField.delegate = self
        // Customisation example
        //        testCollection.customFont = UIFont.boldSystemFont(ofSize: 14)        // Custom font
        //        testCollection.customCornerRadius = 14.0                            // Corner radius of tags
        //        testCollection.customSpacing = 20.0                                    // Spacing between cells
        //        testCollection.customBackgroundColor = UIColor.red                    // Background of cells
        
        
        // These are the tags already added by the user, give an aray of strings to the collection
        if let tags = currentTags {
            productTags.tags = tags
        }
        // These are intended to be all the tags the user has added in the app, which are going to be filtered
        allTags.tags = CompletionTree.getCompletion(tree: Model.hashTagTree!, word: "")
        
        /*
         We set this collection's action to .removeTag,
         becasue these are supposed to be the tags the user has already added
         */
        productTags.action = .removeTag
        
        
        // Set the current controller as the delegate of both collections
        productTags.delegate = self
        allTags.delegate = self
        
        // "testCollection" takes the tags sent by "searchCollection"
        allTags.receiver = productTags
        
        // The tags in "searchCollection" are going to be added, so we set the action to addTag
        allTags.action = .addTag
        
        
        // Set the sender and receiver of the TextField
        addTagsTextField.sender     = allTags
        addTagsTextField.receiver     = productTags
        
        add(productTags, toView: testContainer)
        add(allTags, toView: searchContainerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let receiver = receiver{
            receiver.receiveTags(tags: productTags.tags)
        }
    }
    
    /*
     These methods come from UIViewController now conforming to TKCollectionViewDelegate,
     You use these to do whatever you want when a tag is added or removed (e.g. save to file, etc)
     */
    override func tagIsBeingAdded(name: String?) {
        // Example: save testCollection.tags to UserDefault
        print("added \(name!)")
    }
    
    override func tagIsBeingRemoved(name: String?) {
        print("removed \(name!)")
    }
}

// textField deletage to close keyboard on return
extension TaggsSelectionViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
}
