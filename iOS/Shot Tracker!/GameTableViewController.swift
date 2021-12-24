//
//  GameTableViewController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 9/25/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit
import Firebase


class FireGameData: NSObject{
	var gameNickname: String
	var gameDate: String
	var data: String
	init(gameNickname: String, gameDate: String, data: String){
		self.gameNickname = gameNickname
		self.gameDate = gameDate
		self.data = data
	}
	func toAnyObject() -> Any {
		return [
			"gameNickname": gameNickname,
			"gameDate": gameDate,
			"data": data
		]
	}
}


class GameTableViewController: UITableViewController {
	let ref = Database.database().reference().root
	var refHandle: UInt!
	let date = NSDate()
	//MARK: Properties
	var games = [FireGameData]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//load game data
		getGamesPlayed()

    }
	
	func getGamesPlayed() {
		let userID = Auth.auth().currentUser?.uid
		refHandle = ref.child("games").child(userID!).observe(.childAdded, with: { (snapshot) in
		if let dictionary = snapshot.value as? [String: AnyObject]{
		
		print(dictionary)
		let dictGame = GameClass()
		
		dictGame.setValuesForKeys(dictionary) //this is the line that does not work//
		print("foo")
			
	
		let game = FireGameData(gameNickname: dictGame.value(forKey: "gameNickname") as! String, gameDate: dictGame.value(forKey: "gameDate") as! String, data: dictGame.value(forKey: "data") as! String)
		
		
		self.games.append(game)
		
		
		DispatchQueue.main.async {
		self.tableView.reloadData()
		}
		
		}
		})
		

		/*var dataDictionary: NSDictionary = NSDictionary()
		
		let ref = Database.database().reference().root
		let userID = Auth.auth().currentUser?.uid
		print(userID!)
		ref.child("games").child(userID!).observe(.value, with: { snapshot in
			dataDictionary = snapshot.value as! NSDictionary
		})
		print(dataDictionary)
		self.tableView.reloadData()*/
	}
	

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return games.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		print("Game Count = \(games.count)")
        return games.count
    }
	
	

	
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cellIdentifier = "GameTableViewCell"
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell
		let gameItem = games[indexPath.row]
	
	    cell?.gameDateLabel.text = gameItem.gameDate
		cell?.gameTitleLabel.text = gameItem.gameNickname
		cell?.photoImageView.image = UIImage(named: "show_shot_view.png")

			
		/*as? GameTableViewCell  else {
			fatalError("The dequeued cell is not an instance of GameTableViewCell.")
		}
		// Fetches the appropriate game for the data source layout.
		let game = games[indexPath.row]
		cell.gameDateLabel.text = game.value
		cell.photoImageView.image = UIImage(named: "show_shot_view.png")
		//print(cell)*/

	return cell!
    }
	
	@IBAction func addNameButton(_ sender: UIBarButtonItem) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SS'Z'"
		var stringDate = dateFormatter.string(from: date as Date)
		let shortenedDate = String(Array(stringDate)[...9])
		
		let alert = UIAlertController(title: "New Game",
									  message: "Add a new date",
									  preferredStyle: .alert)
		
		let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
			guard let textField = alert.textFields?.first,
				let text = textField.text else {return}
			
			let newGame = FireGameData(gameNickname: text, gameDate: shortenedDate, data: "")
			
            let gameItemRef = self.ref.child("games").child((Auth.auth().currentUser?.uid)!).child(stringDate)
			
			gameItemRef.setValue(newGame.toAnyObject())
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel",
										 style: .cancel)
		
		alert.addTextField()
		
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		
		present(alert, animated: true, completion: nil)
		
		/*let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
			
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
			
			
		})*/
		
	}
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	
	
	
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

}
