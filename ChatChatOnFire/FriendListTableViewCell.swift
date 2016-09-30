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
    
    fileprivate func setupNameAndProfileImage()  {
        
        if let id = message?.chatPartnerId() {
            //reference to that branch
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                
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
                
                
                }, withCancel: nil)
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 65, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 65, y: (detailTextLabel?.frame.origin.y)!, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    
    
  
    
    //custom imageView
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        //        imageView.image = UIImage(named: "IMG_1729")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    //create a friendButton
    lazy var friendAddButton:UIButton = {
        
        let button = UIButton(type: UIButtonType.system)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Remove Friend", for: UIControlState())
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRemoveFriend), for: .touchUpInside)
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
        
        let button = UIButton(type: UIButtonType.system)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Cancel Friend", for: UIControlState())
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCancelFriend), for: .touchUpInside)
        return button
    }()
    
    func handleCancelFriend( )  {
        
        friendAddButton.isHidden = true
        undoFriend.isHidden = false
        cancelFriendButton.isHidden = true
        
        
    }
    //create a friendButton
    lazy var undoFriend:UIButton = {
        
        let button = UIButton(type: UIButtonType.system)
        //        label.text = "HH:MM:SS"
        
        button.setTitle("Undo", for: UIControlState())
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleUndoFriend), for: .touchUpInside)
        return button
    }()
    
    func handleUndoFriend( )  {
        
        friendAddButton.isHidden = false
        undoFriend.isHidden = true
        cancelFriendButton.isHidden = true
        
        
    }

    
    //custom init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(friendAddButton)
        addSubview(undoFriend)
        addSubview(cancelFriendButton)
        
        addSubview(profileImageView)
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //add iso 9 constraint to View X Y width height
        friendAddButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        friendAddButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        friendAddButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        friendAddButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        //add iso 9 constraint to View X Y width height
        undoFriend.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        undoFriend.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        undoFriend.widthAnchor.constraint(equalToConstant: 150).isActive = true
        undoFriend.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        //add iso 9 constraint to View X Y width height
        cancelFriendButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        cancelFriendButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        cancelFriendButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        cancelFriendButton.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
