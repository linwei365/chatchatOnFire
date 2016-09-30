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
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toID = user?.id else {
            return
        }
        
        observerIsFriend(uid, toID: toID)
        
         let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toID )
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                guard let dictionary =  snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
               
                
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                        
                        self.scrollToLastIndext()
                    })

                }
                
                
                }, withCancel: nil)
            
           
            }, withCancel: nil)
    }
    
    var isFriend:Bool?
    
     func observerIsFriend(_ FromID: String, toID:String ){
        
           let currentUserFriend = Friend()
            let toFriend = Friend()
        let currentUserRef = FIRDatabase.database().reference().child("users").child(FromID).child("friends").child(toID)
        
            currentUserRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                
             
                
                currentUserFriend.isFriend = snapshot.value as? Bool
                
         
                let fromRef = FIRDatabase.database().reference().child("users").child(toID).child("friends").child(FromID)
                
                fromRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                    
                    toFriend.isFriend = snapshot.value as? Bool
                    print("hhh \(currentUserFriend.isFriend)")
                    print("hhb \(toFriend.isFriend)")
                    
                    
                    
                    if currentUserFriend.isFriend == true && toFriend.isFriend == true {
                        
                        self.isFriend = true
                        print("we are friend")
                        
                       
                    }
                    else {
                        
                        self.isFriend = false
                        print("we are not friend")
                    }
                    
                    
                    }, withCancel: nil)
                
                
                }, withCancel: nil)
        
        
        
 
        
    }
    
    
    
    
    
    func scrollToLastIndext()  {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count-1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
    textField.leftViewMode = UITextFieldViewMode.always
    textField.leftView = spacerView
    textField.backgroundColor = UIColor.white
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor(r: 220, g: 220, b: 220).cgColor
    
   
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.scrollsToTop = false
       
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId )
        collectionView?.backgroundColor = UIColor.white
 
 
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
        uploadImageView.leftAnchor.constraint(equalTo: containView.leftAnchor,constant: 4).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProfileImageView)))
        uploadImageView.isUserInteractionEnabled = true
        //add textfield to containVeiw
        containView.addSubview(self.inputTextField)
   
        //create a button
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        //add send button to the containView
        containView.addSubview(sendButton)
        
        //add constraint x y width height
        sendButton.centerYAnchor.constraint(equalTo: containView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containView.rightAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
 
        //add constraint x y width height
        self.inputTextField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor,constant: -8).isActive = true
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: sendButton.heightAnchor,constant: -20).isActive = true

        
        //create UIView a line
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        //add subview to view
        containView.addSubview(seperatorLineView)
        
        //add constraint x y width height
        seperatorLineView.leftAnchor.constraint(equalTo: containView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containView.topAnchor).isActive = true
        
        seperatorLineView.widthAnchor.constraint(equalTo: containView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        
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
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info [UIImagePickerControllerMediaURL] as? URL {
            
            
            handleVideoUrlInfo(videoUrl)
            print(videoUrl)
            
            return
        } else{
            
            handleImageInfo(info as [String : AnyObject])

        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func handleVideoUrlInfo(_ url: URL)   {
        
        let fileName = UUID().uuidString + ".mov"
       let updateTask = FIRStorage.storage().reference().child("message_videos").child(fileName).putFile(url, metadata: nil, completion: { (metaData, error) in
            if error != nil {
                print(error)
                return
            }
            
        if let videoUrl = metaData?.downloadURL()?.absoluteString {
        
            if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
             
                
                self.uploadImageToFirebaseStorage(thumbnailImage, completion: { (imageUrl) in
                    
                    let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject,"videoUrl":videoUrl as AnyObject]
                    
                    if self.isFriend == false {
                        
                        return
                    }
                    self.sendMessageWithProperties(properties)
               
                })

            }

        }
    
        })
        
        
        updateTask.observe(.progress) { (snapshot) in
             print(snapshot.progress?.completedUnitCount)
        }
        
        updateTask.observe(.success) { (snapshot) in
            
            print("done")
             self.dismiss(animated: true, completion: nil)
        }
       
        
    }
    //creates a thumbnail for video on the first frame
    fileprivate func thumbnailImageForFileUrl(_ url:URL)-> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
             let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let error {
            print(error)
        }
            return nil
    
    }
    
    func handleImageInfo(_ info: [String: AnyObject])  {
        
        
        
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
    
    
    
    fileprivate func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        
        let imageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("message_images").child(imageName)
       
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            
            storageRef.put(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if (error != nil){
                    print(error)
                    return
                }
                
                
                if let imageUrl = metaData?.downloadURL()?.absoluteString{
                    
                     completion(imageUrl)
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
    override var canBecomeFirstResponder : Bool {
        //can't see the inputAccessoryView until this returns true
        return true
    }

    
        //textField begin edit action
    func textFieldDidBeginEditing(_ textField: UITextField) {
      setupKeyboardObserver()
        
    }
 
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
          collectionView?.keyboardDismissMode = .interactive
    }
    
    func dismissKeyboard() {
      collectionView?.keyboardDismissMode = .none
     inputTextField.resignFirstResponder()
   
       
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObserver( )  {

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboadDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillAppear), name:UIKeyboardWillShowNotification, object: nil )
//    
//       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name:UIKeyboardWillHideNotification, object: nil )
    
    }
    
    func handleKeyboadDidShow(_ notification: Notification)  {
        
        scrollToLastIndext()
    }

    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[(indexPath as NSIndexPath).item]
        
//        cell.message = message
        
        let currentID = FIRAuth.auth()?.currentUser?.uid
        
        
        
        print("currentID is \(message.toID) \(message.fromID!)")
        
        //if not friend
        if self.isFriend == false {
            
            
            if (message.fromID != currentID ) {
                
                print(message.chatPartnerId())
                cell.message = message
                cell.textView.text = message.text
                
                
                
                
                cell.bubbleView.backgroundColor = UIColor.clear
                if let messageImageUrl =  message.imageUrl {
                    cell.messageImage.loadImageUsingCacheWithUrlString(messageImageUrl)
                    cell.messageImage.isHidden = false
                    
                    
                }
                else {
                    cell.messageImage.isHidden = true
                    //            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
                }
                
                
                
                if let text = message.text {
                    
                    cell.bubbleViewConstraintWith?.constant = estimateFrameForText(text).width + 32
                    cell.textView.isHidden = false
                    
                } else if (message.imageUrl != nil) {
                    cell.textView.isHidden = true
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
                    cell.playButton.isHidden = false
                } else {
                    cell.playButton.isHidden = true
                }
            }
            else {
                
                cell.profileImageView.isHidden = true
                cell.profileImageViewB.isHidden = true
            }
        } else {
            
            
           //if isFriend then do
       
            cell.message = message
            cell.textView.text = message.text
            
            
            
            
            cell.bubbleView.backgroundColor = UIColor.clear
            if let messageImageUrl =  message.imageUrl {
                cell.messageImage.loadImageUsingCacheWithUrlString(messageImageUrl)
                cell.messageImage.isHidden = false
                
                
            }
            else {
                cell.messageImage.isHidden = true
                //            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
            }
            
            
            
            if let text = message.text {
                
                cell.bubbleViewConstraintWith?.constant = estimateFrameForText(text).width + 32
                cell.textView.isHidden = false
                
            } else if (message.imageUrl != nil) {
                cell.textView.isHidden = true
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
                cell.playButton.isHidden = false
            } else {
                cell.playButton.isHidden = true
            }

            
            
        }
     

        
        
        
        ///-------
        
//        cell.message = message
//        cell.textView.text = message.text
//        
//        
//        
//        
//        cell.bubbleView.backgroundColor = UIColor.clearColor()
//        if let messageImageUrl =  message.imageUrl {
//            cell.messageImage.loadImageUsingCacheWithUrlString(messageImageUrl)
//            cell.messageImage.hidden = false
//            
//            
//        }
//        else {
//            cell.messageImage.hidden = true
//            //            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
//        }
//        
//        
//        
//        if let text = message.text {
//            
//            cell.bubbleViewConstraintWith?.constant = estimateFrameForText(text).width + 32
//            cell.textView.hidden = false
//            
//        } else if (message.imageUrl != nil) {
//            cell.textView.hidden = true
//            cell.bubbleViewConstraintWith?.constant = 200
//        }
//        
//        
//        
//        
//        
//        if let profileImageUrl = user!.profileImageUrl {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        } else {
//            cell.profileImageView.image = UIImage(named: "profile_teaser")
//        }
//        
//        
//        setupNameAndProfileImageB(cell.profileImageViewB)
//        
//        
//        setupCell(cell, message: message)
//        
//        if message.videoUrl != nil {
//            cell.playButton.hidden = false
//        } else {
//            cell.playButton.hidden = true
//        }
//        
//
        

        
         return cell
    }
    
    
    
    func setupNameAndProfileImageB(_ profileImageView: UIImageView)  {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        if let id = uid {
            //reference to that branch
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    
          
                    //load image
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        
                        
                         profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                        
                    } else{
                        
                        //fix image changing if url string is nil
                        profileImageView.image = UIImage(named: "profile_teaser")
                    }
                }
 
                }, withCancel: nil)
            
        }
    }
    

    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message)   {
        if message.fromID == FIRAuth.auth()?.currentUser?.uid {
            //blue
        
            
            if message.text != nil {
                cell.bubbleView.backgroundColor = ChatMessageCell.blueBubbleColor
                cell.textView.textColor = UIColor.white
                cell.bubbleViewLeftAnchorConstraint?.isActive = false
                cell.bubbleViewRightAnchorConstraint?.isActive = true
           
            }
          
            cell.profileImageView.isHidden = true
            cell.profileImageViewB.isHidden = false
            
        } else {
            
            if message.text != nil {
                cell.profileImageView.isHidden = false
                cell.profileImageViewB.isHidden = true
                //gray
                cell.bubbleView.backgroundColor = ChatMessageCell.greyBubbleColor
                cell.textView.textColor = UIColor.black
            }
            
        

                cell.bubbleViewLeftAnchorConstraint?.isActive = true
                cell.bubbleViewRightAnchorConstraint?.isActive = false

        
        }
    }
    
    //adjust bounds when rotate screen
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        
        //estimate height
        let message = messages[(indexPath as NSIndexPath).item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        }
        else if let imageHeight = message.imageHeight?.floatValue, let imageWidth = message.imageWidth?.floatValue {
          
            height = CGFloat(imageHeight/imageWidth*200)
            
        }
        
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string:text).boundingRect(with: size, options: options , attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 18)], context: nil)
        
    }
    
    var containerBottomAnchorConstraint: NSLayoutConstraint?

     func handleSendMessage()  {
        if inputTextField.text == "" {
            return
        }
        
        if isFriend == false {
            
            return
        }
        
         let properties = ["text":inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
        
        
        
        inputTextField.text = nil
            
       
    }

    fileprivate func uploadImageWithUrl(_ imageURL: String ,image:UIImage) {
        
        if isFriend == false {
            
            return
        }
        
        let properties: [String: AnyObject] = ["imageUrl": imageURL as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
        
        
    }

    //refract send message

     func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user!.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        
  
        
        
        
        let timeStamp:NSNumber = NSNumber(Int(Date().timeIntervalSince1970))
         var values: [String: AnyObject] = ["toID": toID as AnyObject, "fromID": fromID as AnyObject, "timeStamp":timeStamp]
        
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
        
//        }
        
        //-----------------
 
    }
    
    
    
    
    
 ///
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessage()
       return true
    }
    
    
    //notification
    
    func observeKeyboardNotification()  {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
     }
    
    
    func handleKeyboardWillAppear(_ notification: Notification)   {
        
        
        let keyboardHeight = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let animationDuration =  ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        cgY = -(keyboardHeight?.height)!
        UIView.animate(withDuration: animationDuration!, animations: {
//            self.view.layoutIfNeeded()
        }) 
        
        
    }
    
    
    func handleKeyboardWillHide(_ notification: Notification)   {
        
        let animationDuration =  ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        cgY = 0
        UIView.animate(withDuration: animationDuration!, animations: {
//            self.view.layoutIfNeeded()
        }) 
        
    }
    
    
    //perform zoom in logic
    var startingImageFrame: CGRect?
    var backGround: UIView?
    var startImageView: UIImageView?
    var cgY:CGFloat?
    func peformZoomImageView(_ imageView:UIImageView)  {
        
          startImageView = imageView
          startingImageFrame = imageView.superview?.convert(imageView.bounds, to: nil)
        

        
  
       print(startingImageFrame)
        
        startImageView?.isHidden = true
        let zoomingView =  UIImageView(frame: startingImageFrame!)

        zoomingView.backgroundColor = UIColor.black
        zoomingView.image = imageView.image
        zoomingView.isUserInteractionEnabled = true
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingView.layer.cornerRadius = 16
        zoomingView.layer.masksToBounds = true
        
        
        if let keyWindow =  UIApplication.shared.keyWindow{
//               backGround = UIView(frame: keyWindow.frame)
            backGround = UIView()
            backGround?.translatesAutoresizingMaskIntoConstraints = false
            backGround?.backgroundColor = UIColor.black
            backGround?.alpha = 0
 
            
            
             keyWindow.addSubview(backGround!)
            
            keyWindow.addSubview(zoomingView)
            backGround?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            backGround?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            backGround?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            backGround?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
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
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer)  {
        
        if let zoomOutImageView = tapGesture.view {
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingImageFrame!
                
                self.backGround?.alpha = 0
                self.inputContainerView.alpha = 1
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.layer.masksToBounds = true
                }, completion: { (comoplete:Bool) in
                    self.startImageView?.isHidden = false
                    
                    
                    zoomOutImageView.removeFromSuperview()
            })
            

      
        }
    }
    
    
    
    
    
    
}
