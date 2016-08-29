//
//  ChatMessageCell.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/29/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

    let textView:UITextView = {
         let tV = UITextView()
        tV.text = "some text from custom cell"
        tV.font = UIFont.systemFontOfSize(19)
        tV.translatesAutoresizingMaskIntoConstraints = false
        
         return tV
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.brownColor()
        addSubview(textView)
        
        //ios 9 constraint x y width height
        
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        textView.widthAnchor.constraintEqualToConstant(200).active = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
 