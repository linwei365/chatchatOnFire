//
//  ViewController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/23/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController,LoginViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var messages = [Message]()
    var messagesDictionary =  [String: Message]()
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        
         
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogOut))
        
        let image = UIImage(named: "addNote")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(handleNewMessage))
        
 
//        observeMessages()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    func observeUserMessages( )  {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot:FIRDataSnapshot) in
        
         let userID = snapshot.key
  
            
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observeEventType(.ChildAdded, withBlock: { (snapshot) in
              
                
                let messageId = snapshot.key
 
              
                
                let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
                messagesReference.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                    
                    
                    
                    
                    if let dicionary = snapshot.value as? [String: AnyObject]{
                        
                        let message = Message(dictionary: dicionary)
                        
                        
                      
                        
                        //                self.messages.append(message)
                        
                        if let chatPartnerID = message.chatPartnerId() {
                            //passing the vaule align to the same key accordingly into dictionary
                            
                            self.messagesDictionary[chatPartnerID] = message

                            
                            
                        }
                        
            
                        self.timer?.invalidate()
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        
                        
                        
                    } 
                    
                    }, withCancelBlock: nil)
            
                
                }, withCancelBlock: nil)
            
    
            
            
            }, withCancelBlock: nil)
    }
    
 
    
    var timer: NSTimer?
    
    func handleReloadTable()  {
        
        
        self.messages = Array(self.messagesDictionary.values)
        
        //sort
        self.messages.sortInPlace({ (message1, message2) -> Bool in
            
            return message1.timeStamp?.intValue > message2.timeStamp?.intValue
        })
        
        
        dispatch_async(dispatch_get_main_queue(), {
          
            self.tableView.reloadData()
            
            
        })
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
           
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeysWithDictionary(dictionary)
            
            self.showChatControllerForUser(user)
            
            }, withCancelBlock: nil)
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
        
        
//        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "CellId")
        let message = messages[indexPath.row]
        
        cell.message = message
        
        
        
        return cell
    }
    
    
    func handleNewMessage() {
        
        let newMessageVC:NewMessageTableViewController = NewMessageTableViewController()
            //like a delegate?
            newMessageVC.messageController = self
        
        let navigationController = UINavigationController(rootViewController: newMessageVC)
        presentViewController(navigationController, animated: true , completion: nil)
        
    } 
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        //this is a temp solution while its ok since the data not big it gets called everytime change view back to this view
      //user is not logged in check then sign out
       //option 1
              checkIfUserIsLoggedIn()
        
       //option 2 by protocol
//        let vc:LoginViewController = LoginViewController()
//        vc.delegate = self
//         userLoginSignUpDataDidChange()
        
        
    }
    func userLoginSignUpDataDidChange() {
        checkIfUserIsLoggedIn()
    }
    
    //user is not logged in check then sign out
    func checkIfUserIsLoggedIn( )  {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            //add delay on handleLogOut call
            
            performSelector(#selector(handleLogOut), withObject: nil, afterDelay: 0)
            
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            //fetch
            FIRDatabase.database().reference().child("users").child(uid!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                
                
                if let dictionary = snapshot.value as? [String:AnyObject]{

                    
                    let user = User()
                    
                    user.setValuesForKeysWithDictionary(dictionary)
                    self.setupNavigaionBarWithUser(user)
                    
                    
                    

                }
                
                }, withCancelBlock: nil)
            
        }
    }
    
    
    
    var profileImageUrl:String?
    lazy var profileImageView : UIImageView = {
       let imageView = UIImageView()
        
        return imageView
        
    }()
    
    func setupNavigaionBarWithUser(user:User)  {
        messages.removeAll()
        messagesDictionary.removeAll()
       tableView.reloadData()
        
        observeUserMessages()
 
        
        
        //create an UIView
        let titleView = UIView()
        titleView.frame = CGRectMake(0, 0, 100, 40)
         //create an UIView to contain image and label
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        //add containerView to titleView
        titleView.addSubview(containerView)
        
        //create an imageView
         
        if let profileImageUrl = user.profileImageUrl {
            self.profileImageUrl = profileImageUrl
               profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        } else {
            profileImageView.image = UIImage(named: "profile_teaser")
        }
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        
        //create an UILabel
        let nameLabel = UILabel()
         nameLabel.text = user.name
 
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        //add imageView to UIView
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        
        //ios 9 constraint for imageView x, y, width, height
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active = true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active = true
        
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active = true
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active = true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active = true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active = true
        
        //set UIView to navi title view
        self.navigationItem.titleView = titleView
       titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        titleView.userInteractionEnabled = true
        
    }
    
    
    
    
    //handle image picker ........
    
    //handle image picker controller
    func handleProfileImageView ( )    {
        
        let picker = UIImagePickerController()
  
        picker.delegate = self
        //gives crop operation
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("canceled picker ")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImage:UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            
            
            selectedImage = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImage = originalImage
            
        }
        
        if let image = selectedImage {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            
             FIRDatabase.database().reference().child("users").child(uid!).observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                let user = snapshot.key
                
                print(user)
                
//                         let storageRef = FIRStorage.storage().reference().child("Profile_Images").child("\(user?.imageUID).jpg")
                return
                
                }, withCancelBlock: nil)
            

            
            //output needs to save out the image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    //handle save image
    
    func saveImage()  {
        
      
        
    }
    
    
    
    
    
    
    //handle imagepicker end .....
    
    
    
    
    
    func showChatControllerForUser(user:User)  {
        
        let chatLogViewController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogViewController.user = user
        navigationController?.pushViewController(chatLogViewController, animated: true)
  
    }

    //present login controller
    func handleLogOut( ) {
        //error handle sign out on firebase database side
        do {
            try FIRAuth.auth()?.signOut()
        } catch let sighOutError {
            
            print(sighOutError)
        }
        
        //jump to sigh up page
        let loginController =  LoginViewController()
        presentViewController(loginController, animated: true, completion: nil)
        
        print("loging out")
        
    }


}

