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
    

    func getMessage( )  {
        //getting individual message
        if let fromID =  FIRAuth.auth()?.currentUser?.uid{
            //getting toID
            let messageRef = FIRDatabase.database().reference().child("user-messages").child(fromID)
            
                messageRef.observeSingleEventOfType(.ChildAdded, withBlock: { (snashot) in
                    
                    print("this is from data reconstruction\(snashot.key)")
                    
                    }, withCancelBlock: nil)
            
            
        }
        
       
    }
    
    
    
    
}
