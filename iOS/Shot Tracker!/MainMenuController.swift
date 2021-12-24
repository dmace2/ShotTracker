//
//  PuckTrackerController.swift
//  Shot Tracker
//
//  Created by __ on 10/22/17.
//  Copyright © 2017 . All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

@available(iOS 10.0, *)
class MainMenuController: UIViewController {
	@IBOutlet weak var logInButton: custoButton!
	var userEmail: String!
	var userID: String!
	

	
	var tasks = [ShotLocations]()
	func getData() {
		do {
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let managedContext = appDelegate.persistentContainer.viewContext
			tasks = try managedContext.fetch(ShotLocations.fetchRequest())
			print(tasks)
		}
		catch {
			print("Fetching Failed")
		}
	}
	
	@IBAction func DeleteAllData(){
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ShotLocations"))
		do {
			try managedContext.execute(DelAllReqVar)
		}
		catch {
			print(error)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		userID = Auth.auth().currentUser?.uid
		userEmail = Auth.auth().currentUser?.email
		print(userID)
		if userID != nil{
			logInButton.setTitle("My Account", for: .normal)
			//logInButton.titleLabel!.text! = "My Account"
			print("passed if test")
		}
		else{ logInButton.setTitle("Sign Up/Log In", for: .normal) }
		
		//DeleteAllData()
		//getData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		userID = Auth.auth().currentUser?.uid
		userEmail = Auth.auth().currentUser?.email
		if userID != nil{
			logInButton.setTitle("My Account", for: .normal)
		}
		else{ logInButton.setTitle("Sign Up/Log In", for: .normal) }
	}
	
	@IBAction func didClickAccountSettingsButton(_ sender: Any) {
		print(userID)
		if userID != nil{
			performSegue(withIdentifier: "toAccountSettings", sender: self)
		}
		else{
			performSegue(withIdentifier: "toLoginScreen", sender: self)
		}
		
	}
	
	
	
}


