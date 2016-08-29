//
//  Message.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
   
    var fromID: String?
    var text: String?
    var timeStamp: NSNumber?
    var toID: String?
    
    func chatPartnerId() -> String? {
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
        
    }
}
