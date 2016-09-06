//
//  ChatMessageCell.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/29/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import AVFoundation
class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    var chatLogController: ChatLogController?
    var activityIndicatorView: UIActivityIndicatorView = {
        
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
       indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        indicatorView.hidesWhenStopped = true
     
        return indicatorView
    }()
    
    
    lazy var playButton:UIButton = {
       let button = UIButton(type: .System)
        button.setTitle("play", forState: .Normal)
        let image = UIImage(named: "play")
        button.setImage(image, forState: .Normal)
        button.tintColor = UIColor.whiteColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), forControlEvents: .TouchUpInside)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player : AVPlayer?
    
    func handlePlay( )  {
        
        if let videoUrl = message?.videoUrl, url = NSURL(string: videoUrl){
            player = AVPlayer(URL: url)
             
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
  
            dispatch_async(dispatch_get_main_queue(), { 
                self.player?.play()
            })
            
            
            //after starts to play the video
//            messageImage.alpha = 0
            playButton.hidden = true
            activityIndicatorView.startAnimating()
        }
   
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        
        activityIndicatorView.stopAnimating()
        
        
        
    }
    
    
    let textView:UITextView = {
         let tV = UITextView()
       
        tV.font = UIFont.systemFontOfSize(18)
        tV.backgroundColor = UIColor.clearColor()
        tV.translatesAutoresizingMaskIntoConstraints = false
        tV.textColor = UIColor.whiteColor()
        tV.editable = false
         return tV
    }()
    
    static let blueBubbleColor = UIColor(r: 0, g: 137, b: 249)
    static let greyBubbleColor = UIColor(r: 240, g: 240, b: 240)
    
    let bubbleView: UIView = {
        
        let view = UIView()
//        view.backgroundColor = blueBubbleColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 16
        
        view.layer.masksToBounds = true
        
       return view
    }()
    var bubbleViewConstraintWith:NSLayoutConstraint?
    var bubbleViewLeftAnchorConstraint: NSLayoutConstraint?
     var bubbleViewRightAnchorConstraint: NSLayoutConstraint?
    //custom imageView
    let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IMG_1729")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    
    let profileImageViewB:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_teaser")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
  lazy var messageImage:UIImageView = {
        let imageView = UIImageView()
     
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.userInteractionEnabled = true
        
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
        return imageView
    }()
    
    func handleZoomImage(tapGesture: UITapGestureRecognizer)   {
        
        if let imageView = tapGesture.view as? UIImageView {
        
            self.chatLogController?.peformZoomImageView(imageView)
         }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(profileImageViewB)
        
        
        bubbleView.addSubview(messageImage)
        
        messageImage.addSubview(playButton)
        
        //add iso 9 constraint to View X Y width height
        playButton.centerXAnchor.constraintEqualToAnchor(messageImage.centerXAnchor).active = true
        playButton.centerYAnchor.constraintEqualToAnchor(messageImage.centerYAnchor).active = true
        playButton.widthAnchor.constraintEqualToConstant(50).active = true
        playButton.heightAnchor.constraintEqualToConstant(50).active = true
        
        //add iso 9 constraint to View X Y width height
        playButton.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(messageImage.centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(messageImage.centerYAnchor).active = true
        activityIndicatorView.widthAnchor.constraintEqualToConstant(50).active = true
        activityIndicatorView .heightAnchor.constraintEqualToConstant(50).active = true
        
        //add iso 9 constraint to View X Y width height
        messageImage.topAnchor.constraintEqualToAnchor(bubbleView.topAnchor).active = true
        messageImage.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor).active = true
        messageImage.bottomAnchor.constraintEqualToAnchor(bubbleView.bottomAnchor).active = true
        messageImage.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
        
        //add iso 9 constraint to View X Y width height
        profileImageViewB.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8).active = true
        profileImageViewB.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageViewB.widthAnchor.constraintEqualToConstant(50).active = true
        profileImageViewB.heightAnchor.constraintEqualToConstant(50).active = true
        
        
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        profileImageView.widthAnchor.constraintEqualToConstant(50).active = true
        profileImageView.heightAnchor.constraintEqualToConstant(50).active = true
        
        //ios 9 constraint x y width height
        bubbleViewRightAnchorConstraint = bubbleView.rightAnchor.constraintEqualToAnchor(profileImageViewB.leftAnchor,constant:  -8)
        bubbleViewRightAnchorConstraint?.active = true
        bubbleViewLeftAnchorConstraint = bubbleView.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchorConstraint?.active = false
        
        
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        bubbleViewConstraintWith = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleViewConstraintWith!.active = true
//        bubbleView.widthAnchor.constraintEqualToConstant(200).active = true
        
        //ios 9 constraint x y width height
        
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant:  8).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor ).active = true
//        textView.widthAnchor.constraintEqualToConstant(200).active = true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
 