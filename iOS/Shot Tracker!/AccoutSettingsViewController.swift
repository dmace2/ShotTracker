//
//  AccoutSettingsViewController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 10/16/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit
import Firebase

class AccoutSettingsViewController: UIViewController {
	@IBOutlet weak var userEmailTextBox: UILabel!
	
    override func viewDidLoad() {
		if Auth.auth().currentUser?.email != nil{
			userEmailTextBox.text? = "User Email: \(Auth.auth().currentUser!.email ?? "None")"
		}
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	@IBAction func signOut(_ sender: UIButton){
		try! Auth.auth().signOut()
		self.createAlert(notifTitle: "Logged Out!", notifMessage: "You have been logged out of Shot Tracker.")
		
	}	
	
	func createAlert(notifTitle: String, notifMessage: String){
		var alert = UIAlertController(title: notifTitle, message: notifMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
