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
    
   var users = [User]()
    
    override init() {
            super.init()
        
           self.getMessage { (dictionary) in
            
         }
        self.users = [User]()
        self.getUsers { (users) in
            
            print(users)
        }
 
    }

    func getMessage(completion:(dictionary:[String: AnyObject])->())  {
        //getting individual message
        if let fromID =  FIRAuth.auth()?.currentUser?.uid{
            
            //getting toID
            let messageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            
                messageRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snashot) in
     
                    //getting toID
                    let toID = snashot.key
                    
                    //get messageID
                    self.getPrivateMessageIDWithFromIDAndToID(fromID, toID: toID, completion: { (messageID) in
                        
                        
                       //get message
                        FIRDatabase.database().reference().child("messages").child(messageID).observeEventType(.Value, withBlock: { (snapshotC) in
                            
                            if  let dictionary =  snapshotC.value as? [String: AnyObject]{
                               
                                
                                completion(dictionary: dictionary)
//                                print(dictionary["text"])
                            }

                            }, withCancelBlock: nil)
   
                    })

                    }, withCancelBlock: nil)
            
        }
        
       
    }
    
    
    //get message ID
    func getPrivateMessageIDWithFromIDAndToID(fromID:String, toID:String, completion:(messageID: String)-> ())   {

        let messageIDRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
        messageIDRef.observeEventType(.ChildAdded, withBlock: { (snapshotB) in
            
            //get message ID
          self.messageID = snapshotB.key
       
            
            completion(messageID: self.messageID!)

            }, withCancelBlock: nil)
        
        
    }
    
    
    func getUsers(comppletion:(users:[User])->())  {
        //getting current user uuid
        
        if let currentUserId =  FIRAuth.auth()?.currentUser?.uid {
            
        //getting userReference Observing from UUID
        let userRefence = FIRDatabase.database().reference().child("users")
         userRefence.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
//            print(snapshot.value)
            
            if let dicitonary = snapshot.value as? [String: AnyObject] {
                
                
                
                
                let user:User = User()
                user.id = snapshot.key
                
                
               
                if currentUserId != user.id {
                    
                    //this will crash if the firebase key doesn't match to the string key set up in the model
                    user.setValuesForKeysWithDictionary(dicitonary)
          
                    
                      self.users.append(user)
                    print(self.users)
                    
                    comppletion(users: self.users)
                    
                }
                
                
                
 
                
            }
            
            
            
            }, withCancelBlock: nil)
            
        }
        
        
    
    }
    
    
    
    
    
}
