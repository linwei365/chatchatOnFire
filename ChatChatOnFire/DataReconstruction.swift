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
    
 
    
    override init() {
            super.init()
        
           self.getMessage { (dictionary) in
            
         }
           self.getUser()
 
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
                                print(dictionary["text"])
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
    
    
    func getUser( )  {
        //getting current user uuid
        if let uuid =  FIRAuth.auth()?.currentUser?.uid {
            
        //getting userReference Observing from UUID
        let userRefence = FIRDatabase.database().reference().child(uuid)
         userRefence.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
            
            print(snapshot.key)
            
            
            }, withCancelBlock: nil)
            
        }
        
        
    
    }
    
    
    
    
    
}
