//
//  LoginViewController+handlers.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/26/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit

import Firebase

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    //handle image picker controller
    func handleProfileImageView ( )    {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //gives crop operation
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
        
       
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
      
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImage:UIImage?
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
           
            
           selectedImage = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImage = originalImage
            
        }
        
        if let image = selectedImage {
            loginLogoImageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
  
        
    }
    
    
    //when button clicked  trigger action
    func handleRegister()  {
        //validate
        guard let email = emailTextField.text, password = passwordTextField.text, name = nameTextField.text else {
            
            print("input is not valid")
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user:FIRUser?, error:NSError?) in
            if error != nil {
                
                print(error)
                return
                
            }
            //allow to validate user.uid
            guard let uid = user?.uid else {
                
                print("no uid found")
                return
                
            } 
            //save data to dataStorage in firebase
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("Profile_Images").child("\(imageName).jpg")
            
            
            if self.loginLogoImageView.image == UIImage(named: "IMG_1729"){
                self.loginLogoImageView.image = UIImage(named: "profile_teaser")
            }  
            
            if let profileImage = self.loginLogoImageView.image, uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                
            
            
//            if let uploadData = UIImagePNGRepresentation(self.loginLogoImageView.image!){
              
                //save image upload data to firestorage
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata:FIRStorageMetadata?, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                     print(metadata?.downloadURL())
                    if let userProfileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "email": email, "profileImageUrl": userProfileImageUrl,"imageUID":imageName]
                        self.registerUserToFireDatabaseWithParameters(uid, values: values)
                    }
                    
                })
            }

        })
        print("created succesfully")
    }
    
    
    //refractoring handling register User to database
    
   private  func registerUserToFireDatabaseWithParameters(uid:String, values: [String: AnyObject] )   {
        //firebase datebase refrence url
        let ref = FIRDatabase.database().referenceFromURL("https://chatchatonfire.firebaseio.com/")
        
        //add child branch to users branch and to ref branch
        let userRef =  ref.child("users").child(uid)
        
        //save vaules is a dictionary
        userRef.updateChildValues(values, withCompletionBlock: { (error:NSError?, reference:FIRDatabaseReference) in
            
            if error != nil {
                
                print(error)
                return
                
            }
            
            //saved succesfully
            print("sign up created succesfully")
            //dismiss View
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })
    }
    
    

    
}

 