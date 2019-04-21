//
//  GameSelectorViewController.swift
//  
//
//  Created by Dylan Mace on 10/16/18.
//

import UIKit
import Firebase

class GameSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var gameList: UITableView!
	var ref = Database.database().reference().child("games")
	var date: NSDate!
	
	var gamesList = [GameModel]()
	
	

    override func viewDidLoad() {
        super.viewDidLoad()
		if(Auth.auth().currentUser?.uid != nil){
			ref.child(Auth.auth().currentUser!.uid).observe(DataEventType.value, with: {snapshot in
				if snapshot.childrenCount > 0{
					self.gamesList.removeAll()
					
					for games in snapshot.children.allObjects as! [DataSnapshot] {
						let gameObject = games.value as? [String: AnyObject]
						let gameNickname = gameObject?["gameNickname"]
						let gameDate = gameObject?["gameDate"]
						let gameData = gameObject?["data"]
						let fullDate = gameObject?["gameFBLabel"]
						
						let game = GameModel(gameDate: gameDate as! String, gameNickname: gameNickname as! String, data: gameData as!  String, gameFBLabel: fullDate as! String)
						
						self.gamesList.append(game)
						
					}
					self.gameList.reloadData()
				}
			})
		}
		else{
			createAlert(notifTitle: "Not Logged In!", notifMessage: "Please sign in to track shots.")
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
	@IBAction func addNewGame(_ sender: Any) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SS'Z'"
		date = NSDate()
		var stringDate = dateFormatter.string(from: date as Date)
		let shortenedDate = String(Array(stringDate)[...9])
		
		let alert = UIAlertController(title: "New Game",
									  message: "Add a new date",
									  preferredStyle: .alert)
		
		let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
			guard let textField = alert.textFields?.first,
				let text = textField.text else {return}
			
			let newGame = GameModel(gameDate: shortenedDate, gameNickname: text, data: "", gameFBLabel: stringDate)
			
			
			let gameItemRef = self.ref.child((Auth.auth().currentUser?.uid)!).child(stringDate)
			
			gameItemRef.setValue(newGame.toAnyObject())
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel",
										 style: .cancel)
		
		alert.addTextField()
		
		alert.addAction(saveAction)
		alert.addAction(cancelAction)
		
		present(alert, animated: true, completion: nil)
	}
	
	func createAlert(notifTitle: String, notifMessage: String){
		var alert = UIAlertController(title: notifTitle, message: notifMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
	
	
	
	
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			//firebase delete//
			let stringDateToDelete = gamesList[indexPath.row].gameFBLabel
			print(stringDateToDelete)
			let refToDelete = ref.child(Auth.auth().currentUser!.uid).child(stringDateToDelete!)
			refToDelete.removeValue()
			
			
			
			print("Deleted")
			self.gamesList.remove(at: indexPath.row)
			self.gameList.beginUpdates()
			self.gameList.deleteRows(at: [indexPath], with: .automatic)
			self.gameList.endUpdates()
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return gamesList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "GameDataCell", for: indexPath) as! GameCellTableViewCell
		
		let game: GameModel
		game = gamesList[indexPath.row]
		cell.nicknameLabel.text! = "Game Name: \(game.gameNickname!)"
		cell.dateLabel.text! = "Game Date: \(game.gameDate!)"
		cell.imageToDisplay = UIImageView(image: UIImage(named: "puck.png")!)
		
		return cell
	}
	
	
	

}
