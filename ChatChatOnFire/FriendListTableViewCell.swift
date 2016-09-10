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
class FriendListTableViewCell:UITableViewCell {
    
    var newMessageController:NewMessageTableViewController?
    
     var user: User?
    var message:Message? {
        
        didSet{
            
            
            self.detailTextLabel?.text = message?.text
            setupNameAndProfileImage()
            
 
            
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
                
                
                }, withCancelBlock: nil)
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRectMake(65, (textLabel?.frame.origin.y)!, (textLabel?.frame.width)!, (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRectMake(65, (detailTextLabel?.frame.origin.y)!, (detailTextLabel?.frame.width)!, (detailTextLabel?.frame.height)!)
    }
    
    
    
  
    
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
    //create a friendButton
    lazy var friendAddButton:UIButton = {
        
        let button = UIButton(type: UIButtonType.System)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Remove Friend", forState: .Normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRemoveFriend), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func handleRemoveFriend( )  {
        
        if let  user = user {
         
            print(message?.chatPartnerId())
            
            self.newMessageController?.undoFriendRequest(user)
            
            
        }
        
        
    }
    //create a cancelFriendButton
    lazy var cancelFriendButton:UIButton = {
        
        let button = UIButton(type: UIButtonType.System)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Cancel Friend", forState: .Normal)
        button.hidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancelFriend), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func handleCancelFriend( )  {
        
        friendAddButton.hidden = true
        undoFriend.hidden = false
        cancelFriendButton.hidden = true
        
        
    }
    //create a friendButton
    lazy var undoFriend:UIButton = {
        
        let button = UIButton(type: UIButtonType.System)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Undo", forState: .Normal)
        button.hidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleUndoFriend), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func handleUndoFriend( )  {
        
        friendAddButton.hidden = false
        undoFriend.hidden = true
        cancelFriendButton.hidden = true
        
        
    }

    
    //custom init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(friendAddButton)
        addSubview(undoFriend)
        addSubview(cancelFriendButton)
        
        addSubview(profileImageView)
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(50).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(50).active = true
        
        //add iso 9 constraint to View X Y width height
        friendAddButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 18).active = true
        friendAddButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        friendAddButton.widthAnchor.constraintEqualToConstant(150).active = true
        friendAddButton.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
        
        //add iso 9 constraint to View X Y width height
        undoFriend.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 18).active = true
        undoFriend.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        undoFriend.widthAnchor.constraintEqualToConstant(150).active = true
        undoFriend.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
        
        //add iso 9 constraint to View X Y width height
        cancelFriendButton.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 18).active = true
        cancelFriendButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        cancelFriendButton.widthAnchor.constraintEqualToConstant(150).active = true
        cancelFriendButton.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
