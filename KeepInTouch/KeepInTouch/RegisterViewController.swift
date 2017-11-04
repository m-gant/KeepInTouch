//
//  RegisterViewController.swift
//  KeepInTouch
//
//  Created by Jordan George on 11/3/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    // MARK: - Functions
    
    @objc func handleRegisterButton() {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let username = userNameTextField.text else {
                print("Form is not valid")
                return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                if let errorCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                    switch errorCode {
                        
                    case .errorCodeInvalidEmail:
                        self.alert(title: "Email Error", message: "Invalid Email.")
                    case .errorCodeEmailAlreadyInUse:
                        self.alert(title: "Email Error", message: "Email already in use.")
                    case .errorCodeOperationNotAllowed:
                        print("email and password accounts are not enabled")
                    case .errorCodeWeakPassword:
                        self.alert(title: "Password Error", message: "Password is too weak. Try 6 or more characters.")
                    default:
                        self.alert(title: "Error", message: "Unable to register.")
                        
                    }
                }
                
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let values = ["username": username, "email": email]
            
            self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        })
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        })
    }
    
    @objc func handleLoginButton() {
        present(LoginViewController(), animated: true, completion: nil)
    }
    
    func alert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        if textField == userNameTextField { // Switch focus to other text field
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Views
    
    func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        
        setupLogoImageView()
        setupInputsContainerView()
        setupRegisterButton()
        setupLoginButton()
    }
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 220, green: 220, blue: 220).cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "STHeitiTC-Medium", size: 16)
        
        button.addTarget(self, action: #selector(handleRegisterButton), for: .touchUpInside)
        
        return button
    }()
    
    func setupRegisterButton() {
        //need x, y, width, height constraints
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 220, green: 220, blue: 220).cgColor
        button.titleLabel?.font = UIFont(name: "STHeitiTC-Medium", size: 16)
        
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        
        return button
    }()
    
    func setupLoginButton() {
        loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.delegate = self //for "next" key
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let userNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.delegate = self
        textField.returnKeyType = .next
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.delegate = self
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func setupLogoImageView() {
        //need x, y, width, height constraints
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let height = view.bounds.height/20
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: height).isActive = true
        
        let logoSize = view.bounds.height/3
        logoImageView.widthAnchor.constraint(equalToConstant: logoSize).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: logoSize).isActive = true
    }
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var userNameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(userNameTextField)
        inputsContainerView.addSubview(userNameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints
        userNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        userNameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        userNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userNameTextFieldHeightAnchor = userNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        userNameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        userNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        userNameSeparatorView.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor).isActive = true
        userNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
}


