//
//  ChatLogController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase
class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout {
   
    //this is new
    //the user is set from viewController passed by NewMessageTableViewController
    var user:User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    var messages = [Message]()
    func observeMessages( ) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
         let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                 print(snapshot)
                guard let dictionary =  snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })

                }
                
                
                }, withCancelBlock: nil)
            
           
            }, withCancelBlock: nil)
    }
   lazy var inputTextField:UITextField = {
        //create textField
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "type your message here"
        textField.delegate = self
        return textField
    }()
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId )
//        navigationItem.title = "chat log controller"
        collectionView?.backgroundColor = UIColor.whiteColor()
        setupChatInputArea()
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item ]
        cell.textView.text = message.text
        cell.bubbleViewConstraintWith?.constant = estimateFrameForText(message.text!).width + 32
         return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        //estimate height
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        
        return NSString(string:text).boundingRectWithSize(size, options: options , attributes: [NSFontAttributeName : UIFont.systemFontOfSize(18)], context: nil)
        
    }
    
    
    func setupChatInputArea( )  {
        //create UIView
        let container = UIView()
        container.backgroundColor = UIColor(r: 240, g: 240, b: 240)
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
            
            let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toID)
            recipientUserRef.updateChildValues([messageId : 1])
            
            
            
        }
        
        
        
        
//        print("send .... \(inputTextField.text)")
//        inputTextField.text = ""
    }
    
 
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSendMessage()
       return true
    }
    
    
    
}
