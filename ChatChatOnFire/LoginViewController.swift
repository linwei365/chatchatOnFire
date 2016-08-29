//
//  LoginViewController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/23/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

protocol LoginViewControllerDelegate {
    func userLoginSignUpDataDidChange()
}
class LoginViewController: UIViewController {

    var delegate:LoginViewControllerDelegate? = nil
    
    let loginScrollView:UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.contentSize.height = 1000
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    //create a input container for all inputs email name password
    //block
    let inputContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        //needs this for corner radius to take effect
        view.layer.masksToBounds = true
        
        return view
    }()
    //create a loginRegister button
    //add lazy var to make self avalible
    lazy var loginRegisterButton:UIButton = {
        let button = UIButton(type: UIButtonType.System)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 160 )
        button.setTitle( "Sign Up", forState: UIControlState.Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        
        
        //add target trigger a button action
        button.addTarget(self, action: #selector(handleToggleLoginSignUp), forControlEvents: .TouchUpInside)
        return button
    }()
    //create a segment control
   lazy var loginRegistorSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Sign Up"])
        
            sc.selectedSegmentIndex = 1
            sc.tintColor = UIColor.whiteColor()
        
            sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleLoginRegisterChanged), forControlEvents: .ValueChanged)
        
        return sc
    }()
    
    func handleLoginRegisterChanged( )  {
        let title = loginRegistorSegmentedControl.titleForSegmentAtIndex(loginRegistorSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, forState: .Normal)
        
        //toggle height based on selected index
        inputContainerViewHeightAnchor?.constant = loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //toggle height based on selected index
        nameTextFieldHeightAnchor?.active = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.active = true
        
        //toggle height based on selected index
        emailTextFieldHeightAnchor?.active = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.active = true
        
        //toggle height based on selected index
        passwordTextFieldHeightAnchor?.active = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.active = true
   
    
    }
    
    
    
    //toggle sign up or log in call
    func handleToggleLoginSignUp()  {
        //if segmented index 1 is selected do handleRegister() else do handleLogin()
        
        if  loginRegistorSegmentedControl.selectedSegmentIndex == 1 {
            handleRegister()
        } else {
            handleLogin()
        }
        
        //delegate 
        if (delegate != nil) {
            delegate?.userLoginSignUpDataDidChange()
        }
        
    }
    func handleLogin()   {
        guard let email = emailTextField.text, password = passwordTextField.text else {
           
            print("input is not valid")
            return
        }
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user:FIRUser?, error:NSError?) in
            if error != nil {
             print(error)
                return
            }
            print("\(user?.email) successfully logged in ")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
       
        
        
    }
    
       //create name textfield
    let nameTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let nameTextSeperator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    //create email textfield
    let emailTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextSeperator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //create password textfield
    let passwordTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.secureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextSeperator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //create login Image logo
    lazy var loginLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "IMG_1729")
        imageView.contentMode = .ScaleAspectFill
      imageView.translatesAutoresizingMaskIntoConstraints = false
       
        //handle image profile on gesture touch
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        imageView.userInteractionEnabled = true
        
        return imageView
    }()
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(loginScrollView)
        
        loginScrollView.addSubview(inputContainerView)
        loginScrollView.addSubview(loginRegisterButton)
        loginScrollView.addSubview(loginLogoImageView)
        loginScrollView.addSubview(loginRegistorSegmentedControl)
        
        
        
        setupViewConstraint()
        setupInputContainerViewConstraint()
        loginRegisterButtonConstraint()
        loginLogoImageViewConstraint()
        loginRegisterSegmentedControllConstraint()
        
        
      }
    
    func loginLogoImageViewConstraint( )   {
        loginLogoImageView.centerXAnchor.constraintEqualToAnchor(loginScrollView.centerXAnchor).active = true
        loginLogoImageView.bottomAnchor.constraintEqualToAnchor(loginRegistorSegmentedControl.topAnchor, constant:  -12).active = true
        loginLogoImageView.widthAnchor.constraintEqualToConstant(150).active = true
        loginLogoImageView.heightAnchor.constraintEqualToConstant(150).active = true
    }
    
    //creates constraint for view x, y, width, height constraints
    func setupViewConstraint()   {
        loginScrollView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        loginScrollView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        loginScrollView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        loginScrollView.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
   
        
    }
    //reference  height constraint becomes globlal
    var inputContainerViewHeightAnchor:NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputContainerViewConstraint()  {
        //creates constraint for view x, y, width, height constraints
        inputContainerView.centerXAnchor.constraintEqualToAnchor(loginScrollView.centerXAnchor).active = true
        inputContainerView.centerYAnchor.constraintEqualToAnchor(loginScrollView.centerYAnchor).active = true
        inputContainerView.widthAnchor.constraintEqualToAnchor(loginScrollView.widthAnchor, constant: -24).active = true
        
        //reference inputContainerView  height constraint becomes globlal
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraintEqualToConstant(150)
        inputContainerViewHeightAnchor?.active = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameTextSeperator)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailTextSeperator)
        inputContainerView.addSubview(passwordTextField)
        inputContainerView.addSubview(passwordTextSeperator)
        
        //creates constraint for view x, y, width, height constraints
        nameTextField.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor , constant: 12).active = true
        nameTextField.topAnchor.constraintEqualToAnchor(inputContainerView.topAnchor).active = true
        nameTextField.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        
        //reference height constraint becomes globlal
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.active = true
        
        //creates constraint for view x, y, width, height constraints
        nameTextSeperator.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor).active = true
        nameTextSeperator.topAnchor.constraintEqualToAnchor(nameTextField.bottomAnchor).active = true
        nameTextSeperator.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        nameTextSeperator.heightAnchor.constraintEqualToConstant(1).active = true
        
        //creates constraint for view x, y, width, height constraints
        emailTextField.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor , constant: 12).active = true
        emailTextField.topAnchor.constraintEqualToAnchor(nameTextField.bottomAnchor).active = true
        emailTextField.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        
        //reference inputContainerView  height constraint becomes globlal
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.active = true
        //creates constraint for view x, y, width, height constraints
        emailTextSeperator.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor).active = true
        emailTextSeperator.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        emailTextSeperator.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        emailTextSeperator.heightAnchor.constraintEqualToConstant(1).active = true
        
        //creates constraint for view x, y, width, height constraints
        passwordTextField.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor , constant: 12).active = true
        passwordTextField.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active = true
        passwordTextField.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        
        //reference inputContainerView  height constraint becomes globlal
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraintEqualToAnchor(inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.active = true
        
        //creates constraint for view x, y, width, height constraints
        passwordTextSeperator.leftAnchor.constraintEqualToAnchor(inputContainerView.leftAnchor).active = true
        passwordTextSeperator.topAnchor.constraintEqualToAnchor(passwordTextField.bottomAnchor).active = true
        passwordTextSeperator.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        passwordTextSeperator.heightAnchor.constraintEqualToConstant(1).active = true
        
    }
    
    func loginRegisterButtonConstraint( ) {
        loginRegisterButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        loginRegisterButton.topAnchor.constraintEqualToAnchor(inputContainerView.bottomAnchor, constant: 12).active = true
        loginRegisterButton.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        loginRegisterButton.heightAnchor.constraintEqualToConstant(50).active = true
        
        
    }
    
    func loginRegisterSegmentedControllConstraint( ) {
        
        loginRegistorSegmentedControl.centerXAnchor.constraintEqualToAnchor(loginScrollView.centerXAnchor).active = true
        loginRegistorSegmentedControl.bottomAnchor.constraintEqualToAnchor(inputContainerView.topAnchor, constant: -12).active = true
        loginRegistorSegmentedControl.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor).active = true
        loginRegistorSegmentedControl.heightAnchor.constraintEqualToConstant(30).active = true
        
        
    }

    //give  tatus bar white color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
 
}

extension UIColor {
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    
}