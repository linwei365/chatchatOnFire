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
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var videoUrl: String?
    var friendReqeustMessage:String?
    
    func chatPartnerId() -> String? {
        return fromID == FIRAuth.auth()?.currentUser?.uid ? toID : fromID
        
    }
    
    
    init(dictionary:[String: AnyObject]) {
        super.init()
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
         timeStamp = dictionary["timeStamp"] as? NSNumber
        videoUrl = dictionary["videoUrl"] as? String
        friendReqeustMessage = dictionary["friendReqeustMessage"] as? String
         
    }
}
