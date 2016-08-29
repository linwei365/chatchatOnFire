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
       
        tV.font = UIFont.systemFontOfSize(18)
        tV.backgroundColor = UIColor.clearColor()
        tV.translatesAutoresizingMaskIntoConstraints = false
        tV.textColor = UIColor.whiteColor()
         return tV
    }()
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        
        view.layer.masksToBounds = true
        
       return view
    }()
    var bubbleViewConstraintWith:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        
         addSubview(textView)
       
        //ios 9 constraint x y width height
        bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor,constant:  -8).active = true
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        bubbleViewConstraintWith = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleViewConstraintWith!.active = true
//        bubbleView.widthAnchor.constraintEqualToConstant(200).active = true
        
        //ios 9 constraint x y width height
        
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant:  8).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor ).active = true
//        textView.widthAnchor.constraintEqualToConstant(200).active = true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
 