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
        
      self.getMessage()
        
        
    }
    

    func getMessage()  {
        //getting individual message
        if let fromID =  FIRAuth.auth()?.currentUser?.uid{
            
            //getting toID
            let messageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            
                messageRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snashot) in
     
                    //getting toID
                    let toID = snashot.key
                    
                    //get message ID
                    self.getPrivateMessageWithFromIDToID(fromID, toID: toID)
                    
                    
                    
                    }, withCancelBlock: nil)
            
            
        }
        
       
    }
    
    
    //get message ID
    func getPrivateMessageWithFromIDToID(fromID:String, toID:String)   {

        let messageIDRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
        messageIDRef.observeEventType(.ChildAdded, withBlock: { (snapshotB) in
            
            //get message ID
          self.messageID = snapshotB.key
            
            
            print("this is from data reconstruction \(self.messageID)")

            
            }, withCancelBlock: nil)
        
        
    }
    
    
}
