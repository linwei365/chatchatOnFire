//
//  ChatLogController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController,UITextFieldDelegate {
   
    //this is new
    //the user is set from viewController passed by NewMessageTableViewController
    var user:User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
   lazy var inputTextField:UITextField = {
        //create textField
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "type your message here"
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "chat log controller"
        collectionView?.backgroundColor = UIColor.whiteColor()
        setupChatInputArea()
    }
  
    func setupChatInputArea( )  {
        //create UIView
        let container = UIView()
//        container.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        //add container to view
        view.addSubview(container)
        
        //add constraint x y width height
        container.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        container.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        container.widthAnchor.constraintEqualToAnchor(view.widthAnchor ).active = true
        container.heightAnchor.constraintEqualToConstant(50).active = true
        
        //create a button
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSendMessage), forControlEvents: .TouchUpInside)
        //add send button to the container
        container.addSubview(sendButton)
        
        //add constraint x y width height
        sendButton.centerYAnchor.constraintEqualToAnchor(container.centerYAnchor).active = true
        sendButton.rightAnchor.constraintEqualToAnchor(container.rightAnchor).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(container.heightAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(60).active = true
        
       
         //add inputTextField to container
         container.addSubview(inputTextField)
        
        //add constraint x y width height
        inputTextField.centerYAnchor.constraintEqualToAnchor(sendButton.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputTextField.leftAnchor.constraintEqualToAnchor(container.leftAnchor, constant: 8).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(sendButton.heightAnchor).active = true
        
        //create UIView a line
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        //add subview to view
        container.addSubview(seperatorLineView)
        
        //add constraint x y width height
        seperatorLineView.leftAnchor.constraintEqualToAnchor(container.leftAnchor).active = true
        seperatorLineView.topAnchor.constraintEqualToAnchor(container.topAnchor).active = true
        
        seperatorLineView.widthAnchor.constraintEqualToAnchor(container.widthAnchor).active = true
        seperatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
        
        
    }
    
     func handleSendMessage()  {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user!.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let timeStamp:NSNumber = Int(NSDate().timeIntervalSince1970)
        let vaules = ["text":inputTextField.text!,"toID": toID, "fromID": fromID, "timeStamp":timeStamp]
//        childRef.updateChildValues(vaules)
        
        childRef.updateChildValues(vaules) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            //create a ref
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            let messageId = childRef.key
            //update a dictiontary at this refefence path
            userMessageRef.updateChildValues([messageId : 1])
            
            
        }
        
        
        
        
//        print("send .... \(inputTextField.text)")
//        inputTextField.text = ""
    }
    
 
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSendMessage()
       return true
    }
    
    
    
}
