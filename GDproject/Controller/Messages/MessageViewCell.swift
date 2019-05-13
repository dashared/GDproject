//
//  MessageViewCell.swift
//  GDproject
//
//  Created by cstore on 13/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {

    @IBOutlet weak var dialogName: UILabel!
    
    @IBOutlet weak var lastMessagePreview: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(with dialog: Model.Dialog, user: Model.Users? = nil)
    {
        switch dialog {
            
        case .groupChat(let group):
            dialogName.text = group.group.name
            lastMessagePreview.text = group.lastMessage?.body.markdown
            dateLabel.text = group.lastMessage?.time.getDate()
        case .userChat(let userChat):
            dialogName.text = "👤 \(user!.fullName())"
            lastMessagePreview.text = userChat.lastMessage?.body.markdown
            dateLabel.text = userChat.lastMessage?.time.getDate()
        }
    }
}
