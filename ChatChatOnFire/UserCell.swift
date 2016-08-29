//
//  UserCell.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/28/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

//Create a custome  cell Class
class UserCell:UITableViewCell {
    
    var message:Message? {
        
        didSet{
            
             
            self.detailTextLabel?.text = message?.text
            setupNameAndProfileImage()
            
            if let seconds = self.message?.timeStamp?.doubleValue {
                
                let timeStampeDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormator = NSDateFormatter()
                dateFormator.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormator.stringFromDate(timeStampeDate)
            }
            
        }
    }
    
   private func setupNameAndProfileImage()  {
    
 
     
    
    
    if let id = message?.chatPartnerId() {
        //reference to that branch
        let ref = FIRDatabase.database().reference().child("users").child(id)
        
        ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                
                
                self.textLabel?.text = dictionary["name"] as? String
                
                
                //load image
                if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                    
                    
                    self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    
                } else{
                    
                    //fix image changing if url string is nil
                    self.profileImageView.image = UIImage(named: "profile_teaser")
                }
            }
            
            //convert timeStamp to formated time
            
            
            print(snapshot)
            
            }, withCancelBlock: nil)
        
    }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRectMake(65, (textLabel?.frame.origin.y)!, (textLabel?.frame.width)!, (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRectMake(65, (detailTextLabel?.frame.origin.y)!, (detailTextLabel?.frame.width)!, (detailTextLabel?.frame.height)!)
    }
    
    
    
//    private func setupNameAndProfileImage() {
//        let chatPartnerId: String?
//        
//        if message?.fromID == FIRAuth.auth()?.currentUser?.uid {
//            chatPartnerId = message?.toID
//        } else {
//            chatPartnerId = message?.fromID
//        }
//        
//        if let id = chatPartnerId {
//            let ref = FIRDatabase.database().reference().child("users").child(id)
//            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                
//                if let dictionary = snapshot.value as? [String: AnyObject] {
//                    self.textLabel?.text = dictionary["name"] as? String
//                    
//                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
//                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//                    }
//                }
//                
//                }, withCancelBlock: nil)
//        }
//    }
    
    
    //custom imageView
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: "IMG_1729")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    //create a time label
    let timeLabel:UILabel = {
        
        let label = UILabel()
//        label.text = "HH:MM:SS"
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    //custom init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(timeLabel)
        
        
        addSubview(profileImageView)
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(50).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(50).active = true
        
        //add iso 9 constraint to View X Y width height
        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 18).active = true
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
