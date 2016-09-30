//
//  DataReconstruction.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 9/13/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase


class DataReconstruction: NSObject {
    
    var messageID:String?
    
    var messages = [Message]()
    var users = [User]()
       var messagesDictionary =  [String: Message]()
    
    override init() {
            super.init()
        
        
           self.getMessage { (dictionary) in
 
            print(dictionary)
            let message = Message(dictionary: dictionary)
            if let partnerID = message.chatPartnerId(){
                
                self.messagesDictionary[partnerID] = message
                
                self.handleMessage(self.messagesDictionary)
            }
            
         }
        
        self.getUsers { (users) in
       
        }
 
    }

    func getMessage(_ completion:@escaping (_ dictionary:[String: AnyObject])->())  {
        //getting individual message
        if let fromID =  FIRAuth.auth()?.currentUser?.uid{
            
            //getting toID
            let messageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            
                messageRef.observeSingleEvent(of: .childAdded, with: { (snashot) in
     
                    //getting toID
                    let toID = snashot.key
                    
                    //get messageID
                    self.getPrivateMessageIDWithFromIDAndToID(fromID, toID: toID, completion: { (messageID) in
                        
                        //get message
                        FIRDatabase.database().reference().child("messages").child(messageID).observe(.value, with: { (snapshotC) in
                            
                            if  let dictionary =  snapshotC.value as? [String: AnyObject]{
                                
                                completion(dictionary)
                             }

                            }, withCancel: nil)
   
                    })

                    }, withCancel: nil)
            
        }
        
       
    }
    
    
    var timer: Timer?
    
    func handleMessage(_ messageDic:[String:Message])  {
        
        
 
        
    }
    
    
    //get message ID
    func getPrivateMessageIDWithFromIDAndToID(_ fromID:String, toID:String, completion:@escaping (_ messageID: String)-> ())   {

        let messageIDRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
        messageIDRef.observe(.childAdded, with: { (snapshotB) in
            
           print(snapshotB)
            //get message ID
          self.messageID = snapshotB.key
            
            completion(self.messageID!)
            
             }, withCancel: nil)
        
        
    }
    
    
    func getUsers(_ comppletion:@escaping (_ users:[User])->())  {
        //getting current user uuid
            var users = [User]()
        
        if let currentUserId =  FIRAuth.auth()?.currentUser?.uid {
            
        //getting userReference Observing from UUID
        let userRefence = FIRDatabase.database().reference().child("users")
         userRefence.observe(.childAdded, with: { (snapshot) in
    
             if let dicitonary = snapshot.value as? [String: AnyObject] {
                
                let user:User = User()
                user.id = snapshot.key
  
               //filter out current user profile
                if currentUserId != user.id {
                    
                    //this will crash if the firebase key doesn't match to the string key set up in the model
                    user.setValuesForKeys(dicitonary)
                
                        users.append(user)
                      print(users)
                    
                    comppletion(users)
                    
                }
  
             }
            
            
            }, withCancel: nil)
            
            
        }
  
    
    }

 
    
    
}
