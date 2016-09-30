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
        
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
       indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        indicatorView.hidesWhenStopped = true
     
        return indicatorView
    }()
    
    
    lazy var playButton:UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("play", for: UIControlState())
        let image = UIImage(named: "play")
        button.setImage(image, for: UIControlState())
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player : AVPlayer?
    
    func handlePlay( )  {
        
        if let videoUrl = message?.videoUrl, let url = URL(string: videoUrl){
            player = AVPlayer(url: url)
             
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
  
            DispatchQueue.main.async(execute: { 
                self.player?.play()
            })
            
            
            //after starts to play the video
//            messageImage.alpha = 0
            playButton.isHidden = true
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
       
        tV.font = UIFont.systemFont(ofSize: 18)
        tV.backgroundColor = UIColor.clear
        tV.translatesAutoresizingMaskIntoConstraints = false
        tV.textColor = UIColor.white
        tV.isEditable = false
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    
    let profileImageViewB:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_teaser")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
  lazy var messageImage:UIImageView = {
        let imageView = UIImageView()
     
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
        return imageView
    }()
    
    func handleZoomImage(_ tapGesture: UITapGestureRecognizer)   {
        
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
        playButton.centerXAnchor.constraint(equalTo: messageImage.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: messageImage.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //add iso 9 constraint to View X Y width height
        playButton.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: messageImage.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: messageImage.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView .heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //add iso 9 constraint to View X Y width height
        messageImage.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImage.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        messageImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        
        //add iso 9 constraint to View X Y width height
        profileImageViewB.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        profileImageViewB.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageViewB.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageViewB.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        //add iso 9 constraint to View X Y width height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //ios 9 constraint x y width height
        bubbleViewRightAnchorConstraint = bubbleView.rightAnchor.constraint(equalTo: profileImageViewB.leftAnchor,constant:  -8)
        bubbleViewRightAnchorConstraint?.isActive = true
        bubbleViewLeftAnchorConstraint = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchorConstraint?.isActive = false
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleViewConstraintWith = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewConstraintWith!.isActive = true
//        bubbleView.widthAnchor.constraintEqualToConstant(200).active = true
        
        //ios 9 constraint x y width height
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant:  8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor ).isActive = true
//        textView.widthAnchor.constraintEqualToConstant(200).active = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
 
