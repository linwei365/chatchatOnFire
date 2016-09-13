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
                    
                    let messageIDRef = FIRDatabase.database().reference().child("user-messages").child(fromID).child(toID)
                    
                    messageIDRef.observeEventType(.ChildAdded, withBlock: { (snapshotB) in
                        
                     //get message ID
                        let messageID = snapshotB.key
                        
                        
                        print("this is from data reconstruction \(messageID)")

                        
                        }, withCancelBlock: nil)
                    
                    
                    
                    }, withCancelBlock: nil)
            
            
        }
        
       
    }
    
    
    
    
}
