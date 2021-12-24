//
//  SignInController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 9/15/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//


import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import GoogleSignIn

class SignInController: UIViewController, GIDSignInUIDelegate{
	@IBOutlet  var emailTextField: UITextField!
	@IBOutlet  var passwordTextField: UITextField!
	var iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()

	
	
	//these are the segue functions

	
	
	
	
	func createAlert(notifTitle: String, notifMessage: String){
		var alert = UIAlertController(title: notifTitle, message: notifMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
	
	
	@IBAction func signUpButton(_sender: AnyObject){
		
		guard let email = emailTextField.text, !email.isEmpty else {print("email is empty"); return}
		guard let password = passwordTextField.text, !password.isEmpty else {print("password is empty"); return}
		
		let ref = Database.database().reference().root
		
		if email != "" && password != "" {
			Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
				if error == nil{
					ref.child("users").child((user?.user.uid)!).setValue(email)
					print("signed in as \(email)")
					self.createAlert(notifTitle: "Account Created!", notifMessage: "Signed up as \(email).")
					ref.child("games").child((user?.user.uid)!).child("lastSelectedGame").setValue("None")
					
					
				} else {
					if error != nil{
						//print(error)
						if let errCode = AuthErrorCode(rawValue: error!._code) {
							switch errCode {
								case .invalidEmail:
									print("invalid email")
									// Create an alert message
									self.createAlert(notifTitle: "Invalid Email", notifMessage: "Please check the email address entered")
								case .emailAlreadyInUse:
									print("email in use")	

									self.createAlert(notifTitle: "Email Already In Use", notifMessage: "Please use the 'Log in' button as a user exists with this email")
								case .missingEmail:
									print("no email")
									self.createAlert(notifTitle: "Missing Email", notifMessage: "Please give an email")
								default:
									print("foo")
							}
						}
						
					}
				}
			})
		}
		
	}
	
	@IBAction func logInButton(_sender: AnyObject){
		guard let email = emailTextField.text, let password = passwordTextField.text else {return}
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			
			if let error = error {
				if let errCode = AuthErrorCode(rawValue: error._code) {
					switch errCode {
					case .invalidEmail:
						print("invalid email")
						// Create an alert message
						self.createAlert(notifTitle: "Invalid Email", notifMessage: "Please check the email address entered")
					case .wrongPassword:
						print("wrong password")
						self.createAlert(notifTitle: "Incorrect Password", notifMessage: "Please retry your password or use 'Google Sign In'")
					case .missingEmail:
						print("no email")
						self.createAlert(notifTitle: "Missing Email", notifMessage: "Please give an email")
					case .userNotFound:
						print("no such account")
						self.createAlert(notifTitle: "Account Nonexistent", notifMessage: "Please use the 'Sign Up' button as a user does not exists with this email")
					default:
						print("foo")
					}
				}
			} else if let user = Auth.auth().currentUser {
				self.createAlert(notifTitle: "Authentication Confirmed!", notifMessage: "Signed in as \(email).")
			}
		}
		
	}
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		
		passwordTextField.isSecureTextEntry = true
		
		try! Auth.auth().signOut()     
		GIDSignIn.sharedInstance().signOut()
		GIDSignIn.sharedInstance().disconnect()
		GIDSignIn.sharedInstance().uiDelegate = self
		//GIDSignIn.sharedInstance().signIn()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
