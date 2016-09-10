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
import MobileCoreServices
import AVFoundation


class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
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
        guard let uid = FIRAuth.auth()?.currentUser?.uid, toID = user?.id else {
            return
        }
        
        observerIsFriend(uid, toID: toID)
        
         let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toID )
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                
                guard let dictionary =  snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
               
                
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                        
                        self.scrollToLastIndext()
                    })

                }
                
                
                }, withCancelBlock: nil)
            
           
            }, withCancelBlock: nil)
    }
    
    
    var frineds = [Friend]()
    func observerIsFriend(FromID: String, toID:String ) -> Bool  {
        
           let currentUserFriend = Friend()
            let toFriend = Friend()
        let currentUserRef = FIRDatabase.database().reference().child("users").child(FromID).child("friends").child(toID)
        
            currentUserRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
                
             
                
                currentUserFriend.isFriend = snapshot.value as? Bool
                
                
                print("hhh \(currentUserFriend.isFriend)")
                
                }, withCancelBlock: nil)
        
         let fromRef = FIRDatabase.database().reference().child("users").child(toID).child("friends").child(FromID)
        
        fromRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
            
            toFriend.isFriend = snapshot.value as? Bool
            
            
            print("hhh \(currentUserFriend.isFriend)")
            
            }, withCancelBlock: nil)
        
        if currentUserFriend.isFriend == true && toFriend.isFriend == true {
            
            return true
        }
        
        
        return false
        
    }
    
    
    
    
    
    func scrollToLastIndext()  {
        if messages.count > 0 {
            let indexPath = NSIndexPath(forItem: messages.count-1, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
        
    
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
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollsToTop = false
       
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId )
        collectionView?.backgroundColor = UIColor.whiteColor()
 
 
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatLogController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    }
    

    
    
  //new inputSet up ........
    
    lazy var inputContainerView:UIView = {
       
        let containView = UIView ()
        containView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
        
        //create imageView
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "picA")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //add uploadImageView to containView
        containView.addSubview(uploadImageView)
        
        //add constraint x y width height
        uploadImageView.leftAnchor.constraintEqualToAnchor(containView.leftAnchor,constant: 4).active = true
        uploadImageView.centerYAnchor.constraintEqualToAnchor(containView.centerYAnchor).active = true
        uploadImageView.widthAnchor.constraintEqualToConstant(40).active = true
        uploadImageView.heightAnchor.constraintEqualToConstant(40).active = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProfileImageView)))
        uploadImageView.userInteractionEnabled = true
        //add textfield to containVeiw
        containView.addSubview(self.inputTextField)
   
        //create a button
        let sendButton = UIButton(type: .System)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSendMessage), forControlEvents: .TouchUpInside)
        //add send button to the containView
        containView.addSubview(sendButton)
        
        //add constraint x y width height
        sendButton.centerYAnchor.constraintEqualToAnchor(containView.centerYAnchor).active = true
        sendButton.rightAnchor.constraintEqualToAnchor(containView.rightAnchor).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containView.heightAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(60).active = true
 
        //add constraint x y width height
        self.inputTextField.centerYAnchor.constraintEqualToAnchor(sendButton.centerYAnchor).active = true
        self.inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor,constant: -8).active = true
        self.inputTextField.leftAnchor.constraintEqualToAnchor(uploadImageView.rightAnchor, constant: 8).active = true
        self.inputTextField.heightAnchor.constraintEqualToAnchor(sendButton.heightAnchor,constant: -20).active = true

        
        //create UIView a line
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        //add subview to view
        containView.addSubview(seperatorLineView)
        
        //add constraint x y width height
        seperatorLineView.leftAnchor.constraintEqualToAnchor(containView.leftAnchor).active = true
        seperatorLineView.topAnchor.constraintEqualToAnchor(containView.topAnchor).active = true
        
        seperatorLineView.widthAnchor.constraintEqualToAnchor(containView.widthAnchor).active = true
        seperatorLineView.heightAnchor.constraintEqualToConstant(1).active = true
        
        
        
        
        return containView
    }()
 
    //handle image picker ........
    
    //handle image picker controller
    func handleProfileImageView ( )    { 
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //gives crop operation
//        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeAudio as String]
        picker.mediaTypes = [kUTTypeImage as String]

        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let videoUrl = info [UIImagePickerControllerMediaURL] as? NSURL {
            
            
            handleVideoUrlInfo(videoUrl)
            print(videoUrl)
            
            return
        } else{
            
            handleImageInfo(info)

        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func handleVideoUrlInfo(url: NSURL)   {
        
        let fileName = NSUUID().UUIDString + ".mov"
       let updateTask = FIRStorage.storage().reference().child("message_videos").child(fileName).putFile(url, metadata: nil, completion: { (metaData, error) in
            if error != nil {
                print(error)
                return
            }
            
        if let videoUrl = metaData?.downloadURL()?.absoluteString {
        
            if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
             
                
                self.uploadImageToFirebaseStorage(thumbnailImage, completion: { (imageUrl) in
                    
                    let properties: [String: AnyObject] = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height,"videoUrl":videoUrl]
                    self.sendMessageWithProperties(properties)
               
                })

            }

        }
    
        })
        
        
        updateTask.observeStatus(.Progress) { (snapshot) in
             print(snapshot.progress?.completedUnitCount)
        }
        
        updateTask.observeStatus(.Success) { (snapshot) in
            
            print("done")
             self.dismissViewControllerAnimated(true, completion: nil)
        }
       
        
    }
    //creates a thumbnail for video on the first frame
    private func thumbnailImageForFileUrl(url:NSURL)-> UIImage? {
        let asset = AVAsset(URL: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
             let thumbnailCGImage = try imageGenerator.copyCGImageAtTime(CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(CGImage: thumbnailCGImage)
        }
        catch let error {
            print(error)
        }
            return nil
    
    }
    
    func handleImageInfo(info: [String: AnyObject])  {
        
        
        
        var selectedImage:UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            
            
            selectedImage = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImage = originalImage
            
        }
        
        if let image = selectedImage {
            
          
            uploadImageToFirebaseStorage(image, completion: { (imageUrl) in
                self.uploadImageWithUrl(imageUrl, image: image)
            })
            //output
        }
     }
    
    
    
    private func uploadImageToFirebaseStorage(image: UIImage, completion: (imageUrl: String) -> ()){
        
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("message_images").child(imageName)
       
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if (error != nil){
                    print(error)
                    return
                }
                
                
                if let imageUrl = metaData?.downloadURL()?.absoluteString{
                    
                     completion(imageUrl: imageUrl)
//                    self.uploadImageWithUrl(imageUrl,image: UIImage(data: uploadData)!)
                }
                
                
            })
        }
 
    }
    

    
    
    //handle imagepicker end .....

    
    override var inputAccessoryView: UIView? {
        get {
        
            
            return inputContainerView
        }
    }
    override func canBecomeFirstResponder() -> Bool {
        //can't see the inputAccessoryView until this returns true
        return true
    }

    
        //textField begin edit action
    func textFieldDidBeginEditing(textField: UITextField) {
      setupKeyboardObserver()
        
    }
 
    override func scrollViewDidScroll(scrollView: UIScrollView) {
          collectionView?.keyboardDismissMode = .Interactive
    }
    
    func dismissKeyboard() {
      collectionView?.keyboardDismissMode = .None
     inputTextField.resignFirstResponder()
   
       
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupKeyboardObserver( )  {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboadDidShow), name: UIKeyboardDidShowNotification, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillAppear), name:UIKeyboardWillShowNotification, object: nil )
//    
//       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name:UIKeyboardWillHideNotification, object: nil )
    
    }
    
    func handleKeyboadDidShow(notification: NSNotification)  {
        
        scrollToLastIndext()
    }

    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        
//        cell.message = message
        
        let currentID = FIRAuth.auth()?.currentUser?.uid
        
     
  
        if (message.fromID != currentID ) {
            
            print(message.chatPartnerId())
            cell.message = message
            cell.textView.text = message.text
        
            
            
            
            cell.bubbleView.backgroundColor = UIColor.clearColor()
            if let messageImageUrl =  message.imageUrl {
                cell.messageImage.loadImageUsingCacheWithUrlString(messageImageUrl)
                cell.messageImage.hidden = false
                
                
            }
            else {
                cell.messageImage.hidden = true
                //            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
            }
            
            
            
            if let text = message.text {
                
                cell.bubbleViewConstraintWith?.constant = estimateFrameForText(text).width + 32
                cell.textView.hidden = false
                
            } else if (message.imageUrl != nil) {
                cell.textView.hidden = true
                cell.bubbleViewConstraintWith?.constant = 200
            }
            
            
            
            
            
            if let profileImageUrl = user!.profileImageUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            } else {
                cell.profileImageView.image = UIImage(named: "profile_teaser")
            }
            
            
            setupNameAndProfileImageB(cell.profileImageViewB)
            
            
            setupCell(cell, message: message)
            
            if message.videoUrl != nil {
                cell.playButton.hidden = false
            } else {
                cell.playButton.hidden = true
            }
        }
        else {
            
            cell.profileImageView.hidden = true
            cell.profileImageViewB.hidden = true
        }
        
        
        
        

        
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
 
                }, withCancelBlock: nil)
            
        }
    }
    

    
    private func setupCell(cell: ChatMessageCell, message: Message)   {
        if message.fromID == FIRAuth.auth()?.currentUser?.uid {
            //blue
        
            
            if message.text != nil {
                cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
                cell.textView.textColor = UIColor.whiteColor()
                cell.bubbleViewLeftAnchorConstraint?.active = false
                cell.bubbleViewRightAnchorConstraint?.active = true
           
            }
          
            cell.profileImageView.hidden = true
            cell.profileImageViewB.hidden = false
            
        } else {
            
            if message.text != nil {
                cell.profileImageView.hidden = false
                cell.profileImageViewB.hidden = true
                //gray
                cell.bubbleView.backgroundColor = ChatMessageCell.greyBubbleColor
                cell.textView.textColor = UIColor.blackColor()
            }
            
        

                cell.bubbleViewLeftAnchorConstraint?.active = true
                cell.bubbleViewRightAnchorConstraint?.active = false

        
        }
    }
    
    //adjust bounds when rotate screen
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        //estimate height
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        }
        else if let imageHeight = message.imageHeight?.floatValue, imageWidth = message.imageWidth?.floatValue {
          
            height = CGFloat(imageHeight/imageWidth*200)
            
        }
        
        
        let width = UIScreen.mainScreen().bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        
        return NSString(string:text).boundingRectWithSize(size, options: options , attributes: [NSFontAttributeName : UIFont.systemFontOfSize(18)], context: nil)
        
    }
    
    var containerBottomAnchorConstraint: NSLayoutConstraint?

     func handleSendMessage()  {
        if inputTextField.text == "" {
            return
        }
        
         let properties = ["text":inputTextField.text!]
        sendMessageWithProperties(properties)
        
        
        
        inputTextField.text = nil
            
       
    }

    private func uploadImageWithUrl(imageURL: String ,image:UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties)
        
        
    }

    //refract send message

     func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user!.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        
        if observerIsFriend(fromID, toID: toID) == true {
            
        
        
        let timeStamp:NSNumber = Int(NSDate().timeIntervalSince1970)
         var values: [String: AnyObject] = ["toID": toID, "fromID": fromID, "timeStamp":timeStamp]
        
        //        childRef.updateChildValues(vaules)
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            //create a ref
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
            let messageId = childRef.key
            //update a dictiontary at this refefence path
            userMessageRef.updateChildValues([messageId : 1])
            
            let recipientUserRef = FIRDatabase.database().reference().child("user-messages").child(toID).child(fromID)
            recipientUserRef.updateChildValues([messageId : 1])
            
            
            
        }
        
        }
        
        //-----------------
 
    }
    
    
    
    
    
 ///
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSendMessage()
       return true
    }
    
    
    //notification
    
    func observeKeyboardNotification()  {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillAppear), name: UIKeyboardWillShowNotification, object: self.view.window)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillShowNotification, object: self.view.window)
     }
    
    
    func handleKeyboardWillAppear(notification: NSNotification)   {
        
        
        let keyboardHeight = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let animationDuration =  notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
//        cgY = -(keyboardHeight?.height)!
        UIView.animateWithDuration(animationDuration!) {
//            self.view.layoutIfNeeded()
        }
        
        
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification)   {
        
        let animationDuration =  notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
//        cgY = 0
        UIView.animateWithDuration(animationDuration!) {
//            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //perform zoom in logic
    var startingImageFrame: CGRect?
    var backGround: UIView?
    var startImageView: UIImageView?
    var cgY:CGFloat?
    func peformZoomImageView(imageView:UIImageView)  {
        
          startImageView = imageView
          startingImageFrame = imageView.superview?.convertRect(imageView.bounds, toView: nil)
        

        
  
       print(startingImageFrame)
        
        startImageView?.hidden = true
        let zoomingView =  UIImageView(frame: startingImageFrame!)

        zoomingView.backgroundColor = UIColor.blackColor()
        zoomingView.image = imageView.image
        zoomingView.userInteractionEnabled = true
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingView.layer.cornerRadius = 16
        zoomingView.layer.masksToBounds = true
        
        
        if let keyWindow =  UIApplication.sharedApplication().keyWindow{
//               backGround = UIView(frame: keyWindow.frame)
            backGround = UIView()
            backGround?.translatesAutoresizingMaskIntoConstraints = false
            backGround?.backgroundColor = UIColor.blackColor()
            backGround?.alpha = 0
 
            
            
             keyWindow.addSubview(backGround!)
            
            keyWindow.addSubview(zoomingView)
            backGround?.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
            backGround?.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
            backGround?.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
            backGround?.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
            
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                
                self.backGround?.alpha = 1
                
                self.inputContainerView.alpha = 0
                
                
                
                let height = self.startingImageFrame!.height / self.startingImageFrame!.width * keyWindow.frame.width
                
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                
                zoomingView.center = self.view.center
  

 

                
                }, completion: { (complete:Bool) in
                    
                  self.dismissKeyboard()
            })
 
        }

        
    }
    func handleZoomOut(tapGesture: UITapGestureRecognizer)  {
        
        if let zoomOutImageView = tapGesture.view {
            
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
                zoomOutImageView.frame = self.startingImageFrame!
                
                self.backGround?.alpha = 0
                self.inputContainerView.alpha = 1
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.layer.masksToBounds = true
                }, completion: { (comoplete:Bool) in
                    self.startImageView?.hidden = false
                    
                    
                    zoomOutImageView.removeFromSuperview()
            })
            

      
        }
    }
    
    
    
    
    
    
}
