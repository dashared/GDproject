//
//  InititalsViewCell.swift
//  GDproject
//
//  Created by cstore on 10/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class InititalsViewCell: UITableViewCell {

    @IBOutlet weak var initialsTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with name: String){
        initialsTextField.text = name
    }
}
