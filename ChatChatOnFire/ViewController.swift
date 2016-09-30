//
//  ViewController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/23/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UITableViewController,LoginViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var messages = [Message]()
    var messagesDictionary =  [String: Message]()
    let cellID = "cellID"
    let dataConstruction = DataReconstruction()
 
        var msgDictionary =  [String: AnyObject]()
    
     var usersA = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        msgDictionary = [String: AnyObject]()
        dataConstruction.getMessage { (dictionary) in
            
            
            self.msgDictionary = dictionary
        }
        
        print(msgDictionary["text"])
        
        dataConstruction.getUsers { (users) in
          
            
                self.usersA = users
             
       
        }
      
        print(dataConstruction.messages)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        
        let image = UIImage(named: "addNote")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
 
//        observeMessages()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
    }
    
    func observeUserMessages( )  {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot:FIRDataSnapshot) in
        
         let userID = snapshot.key
  
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
      
                let messageId = snapshot.key
 
                let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
                messagesReference.observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
                if let dicionary = snapshot.value as? [String: AnyObject]{
                let message = Message(dictionary: dicionary)
                //                self.messages.append(message)
                if let chatPartnerID = message.chatPartnerId() {
                //passing the vaule align to the same key accordingly into dictionary
                self.messagesDictionary[chatPartnerID] = message

                 messagesReference.observe(.childRemoved, with: { (snapshot) in
                    
                   
                    
                    self.messagesDictionary.removeValue(forKey: snapshot.key)
                    self.handleReloadTable()
                    
                    }, withCancel: nil)
                            
                        }
                    
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        
                    } 
                    
                    }, withCancel: nil)

                }, withCancel: nil)

            }, withCancel: nil)
    }
    
 
    
    var timer: Timer?
    
    func handleReloadTable()  {
        
        
        self.messages = Array(self.messagesDictionary.values)
        
        //sort
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timeStamp?.int32Value > message2.timeStamp?.int32Value
        })
        
        
        DispatchQueue.main.async(execute: {
          
            self.tableView.reloadData()
            
            
        })
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[(indexPath as NSIndexPath).row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
           
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            
            self.showChatControllerForUser(user)
            
            }, withCancel: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
 
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
   
      
        let currentID = FIRAuth.auth()?.currentUser?.uid
        
        
        let message = messages[(indexPath as NSIndexPath).row]
        
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
        

        
           print(self.usersA[0].email)
        
        return cell
    }
    
    
    func handleNewMessage() {
        
        let newMessageVC:NewMessageTableViewController = NewMessageTableViewController()
            //like a delegate?
            newMessageVC.messageController = self
        
        let navigationController = UINavigationController(rootViewController: newMessageVC)
        present(navigationController, animated: true , completion: nil)
        
    } 
    
    override func viewWillAppear(_ animated: Bool) {
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
            
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
            
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            //fetch
            FIRDatabase.database().reference().child("users").child(uid!).observe(FIRDataEventType.value, with: { (snapshot) in
                
                
                if let dictionary = snapshot.value as? [String:AnyObject]{

                    
                    let user = User()
                    
                    user.setValuesForKeys(dictionary)
                    self.setupNavigaionBarWithUser(user)
                    
                    
                    

                }
                
                }, withCancel: nil)
            
        }
    }
    
    
    
    var profileImageUrl:String?
    lazy var profileImageView : UIImageView = {
       let imageView = UIImageView()
        
        return imageView
        
    }()
    
    func setupNavigaionBarWithUser(_ user:User)  {
        messages.removeAll()
        messagesDictionary.removeAll()
       tableView.reloadData()
        
        observeUserMessages()
 
        
        
        //create an UIView
        let titleView = UIView()
         titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
         //set UIView to navi title view
        self.navigationItem.titleView = titleView
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        titleView.isUserInteractionEnabled = true
   
 
        
        
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
        profileImageView.contentMode = .scaleAspectFill
        
        //create an UILabel
        let nameLabel = UILabel()
         nameLabel.text = user.name
 
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        //add imageView to UIView
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        
        //ios 9 constraint for imageView x, y, width, height
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
  
        
    }
    
    
    
    
    //handle image picker ........
    
    //handle image picker controller
    func handleProfileImageView ( )    {
        
        let picker = UIImagePickerController()
  
        picker.delegate = self
        //gives crop operation
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker ")
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage:UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            
            
            selectedImage = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImage = originalImage
            
        }
        
        if let image = selectedImage, let uploadData = UIImageJPEGRepresentation(image, 0.1) {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
             
                
                if  let userDictionary = snapshot.value as? [String:AnyObject] {
                    
                    let user = User()
                    user.setValuesForKeys(userDictionary)
                    
                    print()
                    
                    if let imageUID = user.imageUID {
                        
                        let storageRef = FIRStorage.storage().reference().child("Profile_Images").child("\(imageUID).jpg")
                        
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata:FIRStorageMetadata?, error) in
                            if error != nil {
                                print(error)
                                return
                            }
                            
                            print(metadata?.downloadURL()?.absoluteString)
                            if let userProfileImageUrl = metadata?.downloadURL()?.absoluteString {
                                
                                let values = ["profileImageUrl": userProfileImageUrl]
                                self.registerUserToFireDatabaseWithParameters(uid!, values: values as [String : AnyObject])
                                
                                
                                
                            }
                            
                        })
                    }
                    
                    
                }
                

                
            })
            
 

            
            //output needs to save out the image
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    //refractoring handling register User to database
    
    fileprivate  func registerUserToFireDatabaseWithParameters(_ uid:String, values: [String: AnyObject] )   {
        //firebase datebase refrence url
        let ref = FIRDatabase.database().reference(fromURL: "https://chatchatonfire.firebaseio.com/")
        
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
            
        } as! (Error?, FIRDatabaseReference) -> Void)
    }

    
    
    
    
    
    
    
    //handle save image
    
    func saveImage()  {
        
      
        
    }
    
 
    
    //handle imagepicker end .....
 
    
    func showChatControllerForUser(_ user:User)  {
        
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
        present(loginController, animated: true, completion: nil)
        
        print("loging out")
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = messages[(indexPath as NSIndexPath).row]
        if let chatPartnerId = message.chatPartnerId(){
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, reference) in
                if error != nil {
                    print(error)
                    return
                    
                }
                
                self.messagesDictionary.removeValue(forKey: message.chatPartnerId()!)
                self.handleReloadTable()
//                self.messages.removeAtIndex(indexPath.row)
//                
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
                
                
            })
            
        }
       
        
        
    }

}

