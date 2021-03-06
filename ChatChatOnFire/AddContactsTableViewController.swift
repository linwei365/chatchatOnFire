//
//  NewMessageTableViewController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/26/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

class AddContactsTableViewController: UITableViewController {
    
    var addContactController:NewMessageTableViewController?
    let chatLogController = ChatLogController()
    var users = [User]()
    let cellID = "Cell"
    let currentUser = User ()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.register(AddContactListTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.allowsSelection = false
        self.navigationItem.title = "Add Contacts"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelButtonAction))
        
        
        
        fetchUsers()
        
        
    }
    
    func fetchUsers( )  {
        FIRDatabase.database().reference().child("users").observe(FIRDataEventType.childAdded , with: { (snapshot:FIRDataSnapshot) in
            
            if let dicitonary = snapshot.value as? [String: AnyObject] {
                
                
                
                
                let user:User = User()
                user.id = snapshot.key
                
                
                let currentUserId = FIRAuth.auth()?.currentUser?.uid
                
                
                if currentUserId != user.id {
                    
                    //this will crash if the firebase key doesn't match to the string key set up in the model
                    user.setValuesForKeys(dicitonary)
                    //safer way
                    //                user.name = dicitonary["name"] as! String
                    //                user.email = dicitonary["email"] as! String
                    
                    
                    self.users.append(user)
                } else {
                    
                    self.currentUser.setValuesForKeys(dicitonary)
                }
               
                
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
            
            }, withCancel: nil)
        
    }
    
    
    
    func handleCancelButtonAction()  {
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID , for: indexPath) as! AddContactListTableViewCell
        
        //        let  cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellID)
        
        
        let user = users[(indexPath as NSIndexPath).row]
        
        
        cell.user = user
        cell.addContactsController = self
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
 
        
       print( isFriend)
        
        
        if let profileImageUrl = user.profileImageUrl {
            
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            
        } else{
            
            //fix image changing if url string is nil
            cell.profileImageView.image = UIImage(named: "profile_teaser")
        }
        
 
        
        return cell
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
    
    func sendFriendRequest(_ user: User)   {
        
        
      
        
      
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
           
            if let incomingUserId = user.id {
              
                let ref = FIRDatabase.database().reference().child("users").child(uid).child("friends").child(incomingUserId)
                
                //set user's friends list isFriend to true
               let value = ["isFriend":true]
                ref.updateChildValues(value)
                
                ref.setValue(value, andPriority: nil, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    let properties = ["text":"you have a friend reqeust from \(self.currentUser.name)"]
//                    self.chatLogController.sendMessageWithProperties(properties)
                     self.sendMessageWithProperties(properties as [String : AnyObject], user: user)
                    
                    print(ref)
                    
                })
                //send a private request message toUser
              
                //            print("send request \(user.id)")
            }
            

        }
 
        
    }
    
    func undoFriendRequest(_ user: User)   {
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            if let incomingUserId = user.id {
                
                let ref = FIRDatabase.database().reference().child("users").child(uid).child("friends").child(incomingUserId)
                
                //set user's friends list isFriend to true
                let value = ["isFriend":false]
              
                
                 
                
                ref.setValue(value, andPriority: nil, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
 
                    
                })
 
            }
            
            
        }
        
        
    }
    
    
    
    
    func sendMessageWithProperties(_ properties: [String: AnyObject] , user: User) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user.id!
        let fromID = FIRAuth.auth()!.currentUser!.uid
        let timeStamp:NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
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
 
        
    }
//    var messageController:ViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        dismissViewControllerAnimated(true) {
//            
//            
//            
//            
//            let user = self.users[indexPath.row]
//            
//            
//            //pass user
//            self.messageController?.showChatControllerForUser(user)
//            
//        }
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}


