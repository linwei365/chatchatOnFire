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
                
                let timeStampeDate = Date(timeIntervalSince1970: seconds)
                let dateFormator = DateFormatter()
                dateFormator.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormator.string(from: timeStampeDate)
            }
            
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
    //create a time label
    let timeLabel:UILabel = {
        
        let label = UILabel()
//        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    //custom init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(timeLabel)
        
        
        addSubview(profileImageView)
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //add iso 9 constraint to View X Y width height
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
