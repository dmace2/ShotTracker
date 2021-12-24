//
//  TableViewController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 9/25/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit
import Firebase


class TableViewController: UIViewController {
    var firebaseData: NSDictionary!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGamesPlayed()
        title = "Game Selector"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Game", message: "Add a new date", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
        let ref = Database.database().reference().root
        let key = ref.child("users").childByAutoId().key
        guard let userKey = Auth.auth().currentUser?.uid else {return}
        
        ref.child("games").child(userKey).observeSingleEvent(of: .value, with: { snapshot in
            var count = "0"
            if let values = snapshot.value as? [String] {
                count = String(describing: values.count)
            }
            var newFavorite = [String: String]()
            newFavorite[count] = key
            ref.child("games").child(userKey).updateChildValues(newFavorite)
            //self.viewController.presentAlertWithTitle(title: "Congrats!", message:"you have successfully added a game" )
            
            
        })
        
    }
    
    func getGamesPlayed() {
        let ref = Database.database().reference().root
        let userID = Auth.auth().currentUser?.uid
        print(userID)
        ref.child("games").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value!)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
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
