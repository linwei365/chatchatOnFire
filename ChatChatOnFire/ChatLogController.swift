//
//  ChatLogController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout {
   
    //this is new
    //the user is set from viewController passed by NewMessageTableViewController
    var user:User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var url: String?
    var viewController:ViewController? {
        didSet {
             url = viewController?.profileImageUrl
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
         textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
    
    let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
    textField.leftViewMode = UITextFieldViewMode.Always
    textField.leftView = spacerView
    textField.backgroundColor = UIColor.whiteColor()
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor(r: 220, g: 220, b: 220).CGColor
    
   
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        collectionView?.scrollsToTop = false
       
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId )

        collectionView?.backgroundColor = UIColor.whiteColor()
        setupChatInputArea()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        setupKeyboardObserver()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupKeyboardObserver( )  {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillAppear), name:UIKeyboardWillShowNotification, object: nil )
    
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name:UIKeyboardWillHideNotification, object: nil )
    
    }
    
    func handleKeyboardWillAppear(notification: NSNotification)   {
        
        
        let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let animationDuration =  notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
             containerBottomAnchorConstraint?.constant = -(keyboardHeight?.height)!
        UIView.animateWithDuration(animationDuration!) { 
            self.view.layoutIfNeeded()
        }
   
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleKeyboardWillHide(notification: NSNotification)   {
        
        let animationDuration =  notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        containerBottomAnchorConstraint?.constant = 0
        UIView.animateWithDuration(animationDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        cell.bubbleViewConstraintWith?.constant = estimateFrameForText(message.text!).width + 32
       
        
        
        
        if let profileImageUrl = user!.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        } else {
           cell.profileImageView.image = UIImage(named: "profile_teaser")
        }

        
        setupNameAndProfileImageB(cell.profileImageViewB)
        
        
        setupCell(cell, message: message)
       
        
         return cell
    }
    
    
    func setupNameAndProfileImageB(profileImageView: UIImageView)  {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        if let id = uid {
            //reference to that branch
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    
          
                    //load image
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        
                        
                         profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                        
                    } else{
                        
                        //fix image changing if url string is nil
                        profileImageView.image = UIImage(named: "profile_teaser")
                    }
                }
                                
                
                print(snapshot)
                
                }, withCancelBlock: nil)
            
        }
    }
    
    
    
    private func setupCell(cell: ChatMessageCell, message: Message)   {
        if message.fromID == FIRAuth.auth()?.currentUser?.uid {
            //blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
            cell.textView.textColor = UIColor.whiteColor()
            cell.bubbleViewLeftAnchorConstraint?.active = false
            cell.bubbleViewRightAnchorConstraint?.active = true
            cell.profileImageView.hidden = true
            cell.profileImageViewB.hidden = false
            
            
        } else {
            cell.profileImageView.hidden = false
            cell.profileImageViewB.hidden = true
            //gray
            cell.bubbleView.backgroundColor = ChatMessageCell.greyBubbleColor
            cell.textView.textColor = UIColor.blackColor()
             cell.bubbleViewLeftAnchorConstraint?.active = true
             cell.bubbleViewRightAnchorConstraint?.active = false
        }
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
    
    var containerBottomAnchorConstraint: NSLayoutConstraint?
    
    func setupChatInputArea( )  {
        //create UIView
        let container = UIView()
        container.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        //add container to view
        view.addSubview(container)
        
        //add constraint x y width height
        container.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
      
        container.widthAnchor.constraintEqualToAnchor(view.widthAnchor ).active = true
        container.heightAnchor.constraintEqualToConstant(50).active = true
        containerBottomAnchorConstraint = container.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        containerBottomAnchorConstraint?.active = true
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
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor,constant: -8).active = true
        inputTextField.leftAnchor.constraintEqualToAnchor(container.leftAnchor, constant: 8).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(sendButton.heightAnchor,constant: -20).active = true
        
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
    
    
    @IBAction func handleLogTokenTouch(sender: UIButton) {
        // [START get_iid_token]
        let token = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(token!)")
        // [END get_iid_token]
    }
    
    @IBAction func handleSubscribeTouch(sender: UIButton) {
        // [START subscribe_topic]
        FIRMessaging.messaging().subscribeToTopic("/topics/news")
        print("Subscribed to news topic")
        // [END subscribe_topic]
    }
 
    func sendPNMessage() {
        FIRMessaging.messaging().sendMessage(
            ["body": "hey"],
            to: "TOKEN_ID",
            withMessageID: "1",
            timeToLive: 108)
    }
    
     func handleSendMessage()  {
        if inputTextField.text == "" {
            return
        }
        sendPNMessage()
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
        inputTextField.text = nil
            
       
    }
    
 
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSendMessage()
       return true
    }
    
    
    
}
