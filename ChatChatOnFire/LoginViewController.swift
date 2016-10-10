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
class LoginViewController: UIViewController, UITextFieldDelegate {

    var delegate:LoginViewControllerDelegate? = nil
    
   lazy var loginScrollView:UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.contentSize.height = 1000
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        return scrollView
    }()
    
    //create a input container for all inputs email name password
    //block
    let inputContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        //needs this for corner radius to take effect
        view.layer.masksToBounds = true
        
        return view
    }()
    //create a loginRegister button
    //add lazy var to make self avalible
    lazy var loginRegisterButton:UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 160 )
        button.setTitle( "Sign Up", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        
        //add target trigger a button action
        button.addTarget(self, action: #selector(handleToggleLoginSignUp), for: .touchUpInside)
        return button
    }()
    //create a segment control
   lazy var loginRegistorSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Sign Up"])
        
            sc.selectedSegmentIndex = 1
            sc.tintColor = UIColor.white
        
            sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleLoginRegisterChanged), for: .valueChanged)
        
        return sc
    }()
    
    func handleLoginRegisterChanged( )  {
        let title = loginRegistorSegmentedControl.titleForSegment(at: loginRegistorSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        //toggle height based on selected index
        inputContainerViewHeightAnchor?.constant = loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //toggle height based on selected index
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //toggle height based on selected index
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //toggle height based on selected index
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: loginRegistorSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
   
    
    }
    
    // dissmis keyboard
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       
//    }
    
    func handleTapGesture()  {
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
        guard let email = emailTextField.text, let password = passwordTextField.text else {
           
            print("input is not valid")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user , error ) in
            if error != nil {
             print(error)
                return
            }
            print("\(user?.email) successfully logged in ")
            self.dismiss(animated: true, completion: nil)
        })
       
        
        
    }
    
       //create name textfield
    lazy var nameTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.delegate = self
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
    lazy var emailTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.delegate = self
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
    lazy var passwordTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
         textField.delegate = self
        textField.isSecureTextEntry = true
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
      imageView.translatesAutoresizingMaskIntoConstraints = false
       
        //handle image profile on gesture touch
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
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
        loginLogoImageView.centerXAnchor.constraint(equalTo: loginScrollView.centerXAnchor).isActive = true
        loginLogoImageView.bottomAnchor.constraint(equalTo: loginRegistorSegmentedControl.topAnchor, constant:  -12).isActive = true
        loginLogoImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginLogoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    //creates constraint for view x, y, width, height constraints
    func setupViewConstraint()   {
        loginScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        loginScrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
   
        
    }
    //reference  height constraint becomes globlal
    var inputContainerViewHeightAnchor:NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputContainerViewConstraint()  {
        //creates constraint for view x, y, width, height constraints
        inputContainerView.centerXAnchor.constraint(equalTo: loginScrollView.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: loginScrollView.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: loginScrollView.widthAnchor, constant: -24).isActive = true
        
        //reference inputContainerView  height constraint becomes globlal
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTextField)
        inputContainerView.addSubview(nameTextSeperator)
        inputContainerView.addSubview(emailTextField)
        inputContainerView.addSubview(emailTextSeperator)
        inputContainerView.addSubview(passwordTextField)
        inputContainerView.addSubview(passwordTextSeperator)
        
        //creates constraint for view x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor , constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        //reference height constraint becomes globlal
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //creates constraint for view x, y, width, height constraints
        nameTextSeperator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameTextSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameTextSeperator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //creates constraint for view x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor , constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        //reference inputContainerView  height constraint becomes globlal
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        //creates constraint for view x, y, width, height constraints
        emailTextSeperator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailTextSeperator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailTextSeperator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //creates constraint for view x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor , constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        
        //reference inputContainerView  height constraint becomes globlal
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        //creates constraint for view x, y, width, height constraints
        passwordTextSeperator.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        passwordTextSeperator.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordTextSeperator.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func loginRegisterButtonConstraint( ) {
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    func loginRegisterSegmentedControllConstraint( ) {
        
        loginRegistorSegmentedControl.centerXAnchor.constraint(equalTo: loginScrollView.centerXAnchor).isActive = true
        loginRegistorSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        loginRegistorSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegistorSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
    }

    //give  tatus bar white color
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
 
}

extension UIColor {
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    
}
