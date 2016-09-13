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
    let dataConstruction = DataReconstruction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        dataConstruction.getMessage()
        
        
        
        
        

        
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

                 messagesReference.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
                    
                  
                    
                    self.messagesDictionary.removeValueForKey(snapshot.key)
                    self.handleReloadTable()
                    
                    }, withCancelBlock: nil)
                            
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
        
 
        
        let currentID = FIRAuth.auth()?.currentUser?.uid
        
        
        if isFriend == false {
            
            if messages.count > 0 {
                
                
                for message  in messages{
                    
                    if (message.fromID != currentID ) {
                        
                        print(message.chatPartnerId()! + " k")
                        return messages.count
                    }
                }
                
                
            }
                
            else {
                
                
                return 0
            }

        } else {
        
            return messages.count
        }
        
        
        return 0
      
    }
    
    
 
    
    
    var isFriend:Bool?
    
    func observerIsFriend(FromID: String, toID:String ){
        
        let currentUserFriend = Friend()
        let toFriend = Friend()
        let currentUserRef = FIRDatabase.database().reference().child("users").child(FromID).child("friends").child(toID)
        
        currentUserRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
            
            
            
            currentUserFriend.isFriend = snapshot.value as? Bool
            
            
            let fromRef = FIRDatabase.database().reference().child("users").child(toID).child("friends").child(FromID)
            
            fromRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
                
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
                
                
                }, withCancelBlock: nil)
            
            
            }, withCancelBlock: nil)
        
        
        
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! UserCell
   
      
        let currentID = FIRAuth.auth()?.currentUser?.uid
        
        
        let message = messages[indexPath.row]
        
        if isFriend == false {
           
            if (message.fromID != currentID ) {
                
                print(message.chatPartnerId())
                cell.message = message
            }
        }
        else {
               cell.message = message
            
        }
        
        
//    cell.message = message
        

        
        
        
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
    
         //set UIView to navi title view
        self.navigationItem.titleView = titleView
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        titleView.userInteractionEnabled = true
   
 
        
        
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
        
        if let image = selectedImage, uploadData = UIImageJPEGRepresentation(image, 0.1) {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
             
                
                if  let userDictionary = snapshot.value as? [String:AnyObject] {
                    
                    let user = User()
                    user.setValuesForKeysWithDictionary(userDictionary)
                    
                    print()
                    
                    if let imageUID = user.imageUID {
                        
                        let storageRef = FIRStorage.storage().reference().child("Profile_Images").child("\(imageUID).jpg")
                        
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata:FIRStorageMetadata?, error) in
                            if error != nil {
                                print(error)
                                return
                            }
                            
                            print(metadata?.downloadURL()?.absoluteString)
                            if let userProfileImageUrl = metadata?.downloadURL()?.absoluteString {
                                
                                let values = ["profileImageUrl": userProfileImageUrl]
                                self.registerUserToFireDatabaseWithParameters(uid!, values: values)
                                
                                
                                
                            }
                            
                        })
                    }
                    
                    
                }
                

                
            })
            
 

            
            //output needs to save out the image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    
    //refractoring handling register User to database
    
    private  func registerUserToFireDatabaseWithParameters(uid:String, values: [String: AnyObject] )   {
        //firebase datebase refrence url
        let ref = FIRDatabase.database().referenceFromURL("https://chatchatonfire.firebaseio.com/")
        
        //add child branch to users branch and to ref branch
        let userRef =  ref.child("users").child(uid)
        
        //save vaules is a dictionary
        userRef.updateChildValues(values, withCompletionBlock: { (error:NSError?, reference:FIRDatabaseReference) in
            
            if error != nil {
                
                print(error)
                return
                
            }
            
            //saved succesfully
            print("sign up created succesfully")
            //dismiss View
//            self.dismissViewControllerAnimated(true, completion: nil)
            
        })
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId(){
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValueWithCompletionBlock({ (error, reference) in
                if error != nil {
                    print(error)
                    return
                    
                }
                
                self.messagesDictionary.removeValueForKey(message.chatPartnerId()!)
                self.handleReloadTable()
//                self.messages.removeAtIndex(indexPath.row)
//                
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                
                
            })
            
        }
       
        
        
    }

}

