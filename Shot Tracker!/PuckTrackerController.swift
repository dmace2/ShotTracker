//
//  PuckTrackerController.swift
//  Shot Tracker
//
//  Created by ___ on 10/22/17.
//  Copyright © 2017 __. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import FirebaseAuth
import Firebase

@available(iOS 10.0, *)
class PuckTrackerController: UIViewController {
	@IBOutlet weak var rink: UIImageView!
	
	//outlets for the buttons
	@IBOutlet weak var possB: UIButton!
	@IBOutlet weak var sqB: UIButton!
	@IBOutlet weak var rbcB: UIButton!
	@IBOutlet weak var wsB: UIButton!
	@IBOutlet weak var goalB: UIButton!
	@IBOutlet weak var skateB: UIButton!
	@IBOutlet var periods: [UILabel]!
	
	// for the stack view
	@IBOutlet var periodButtons: [UIButton]!
	@IBOutlet weak var PeriodSelText: UILabel!
	@IBOutlet weak var perShots: UILabel!
	@IBOutlet weak var totalShots: UILabel!
	
	
	enum Periods: String {
		case p1 = "Period 1"
		case p2 = "Period 2"
		case p3 = "Period 3"
		case ot = "Overtime"
		case all = "All"
	}
	
	//for the CoreData mold
	var tasks = [ShotLocations]()
	var shotSequences = [[ShotLocations]]()
	
	//firebase important data
	let ref = Database.database().reference().root
	var pucksFromFirebase = [PuckModel]()
	var sequencesFromFirebase = [[PuckModel]]()
	var gameToBeWorkingOn: GameModel!
	var dataCounterValue: Int! //ticker when adding shots for child title
	
	//drawing onscreen
	var linesBetweenShots = [CAShapeLayer]()
	var pucksBetweenShots = [UIImageView]()
	var colors = [UIColor]()
	let pView = UIImageView(image: UIImage(named: "puck.png")!)
	
	//positioning values on screen for important landmarks
	let screenWidth = UIScreen.main.bounds.width
	let screenHeight = UIScreen.main.bounds.height
	let midCreaseH = (330/411)*UIScreen.main.bounds.height
	var r: CGFloat = 0
	
	var buttonLastClicked = ""
	
	//for iterating through for loops
	var lastpuck: CGPoint = CGPoint(x: 0, y: 0)
	var currpos: CGPoint = CGPoint(x: 0, y: 0)
	
	
	//FIREBASE DATA MODYFYING FUNCTIONS
	func getData() {
		/*do {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		tasks = try managedContext.fetch(ShotLocations.fetchRequest())
		//print("Tasks: \(tasks)")
		}
		catch {
		print("Fetching Failed")
		}*/
		ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").observe(DataEventType.value, with: {snapshot in
			if snapshot.childrenCount > 0{
				self.pucksFromFirebase.removeAll()
				
				for games in snapshot.children.allObjects as! [DataSnapshot] {
					let gameObject = games.value as? [String: Any]
					//print(gameObject)
					let gameX = gameObject?["x"] as! CGFloat
					//print(gameX)
					
					
					let gameY = gameObject?["y"] as! CGFloat
					
					let gameShotType = gameObject?["shotType"]! as! String
					let gamePeriod = gameObject?["period"] as! String
					let gameNewSeqBool = gameObject?["newSequenceBool"] as! Bool
					//print(gameNewSeqBool)
					/*var newBool: Bool = false
					if gameNewSeqBool == "true"{
						newBool = true
					}*/
					
					
					let game = PuckModel(x_: gameX , y_: gameY , sT_: gameShotType , p_: gamePeriod as! String, nSB_: gameNewSeqBool )
					
					self.pucksFromFirebase.append(game)
					//print(game.toAnyObject())
					
				}
				//print(self.pucksFromFirebase.count)
			}
			else{print("no data for this game")}
		})
	}
	
	func deleteAllData(){ //not sure if this works
		let referenceToChild = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data")
		referenceToChild.removeValue()
		pucksFromFirebase.removeAll()
		/*let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ShotLocations"))
		do {
		try managedContext.execute(DelAllReqVar) //deletes all data from CoreData
		}
		catch {
		print(error)
		}
		tasks.removeAll() //deletes all current local data
		(UIApplication.shared.delegate as! AppDelegate).saveContext()*/
	}
	
	//BUTTON CLICK FUNCTIONS
	@IBAction func undoShot(_ sender: UIButton) {
		/*if(tasks.count > 0){
			let tempShots = tasks[0...tasks.count - 2]
			
			deleteAllData() //calls delete function
			
			for var i in 0...tempShots.count - 1{
				makeNewShotEntity(x: CGFloat(tempShots[i].x), y: CGFloat(tempShots[i].y), shotType: tempShots[i].shotType!, period: tempShots[i].period!, newSequenceBool: tempShots[i].newSequence)
			}
			getData()
		}*/
		if pucksFromFirebase.count > 0{
			//let tempShots = pucksFromFirebase[0...pucksFromFirebase.count - 2]
			let referenceToChild = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count-1))
			referenceToChild.removeValue() //remove last puck from firebase
			pucksFromFirebase.removeLast() //remove locally
			dataCounterValue = pucksFromFirebase.count //fox data counter value for data saving
			//deleteAllData()
			/*for var i in 0...tempShots.count - 1{
				makeNewShotEntity(x: CGFloat(tempShots[i].x!), y: CGFloat(tempShots[i].y!), shotType: tempShots[i].shotType!, period: tempShots[i].period!, newSequenceBool: tempShots[i].newSequenceBool!)
			}*/
			//getData()
		}
	}
	
	@IBAction func deadSequence(_ sender: UIButton) {
		if pucksFromFirebase.count > 0{
			var last_element_to_include = 0
			let referenceToData = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data")
			for i in stride(from: pucksFromFirebase.count - 1, through: 0, by: -1){
				let tempPuck = pucksFromFirebase[i]
				let tempShotType = tempPuck.shotType!
				if tempShotType != "Pass" && tempShotType != "Same Sequence" && tempShotType != "Skate"{ //if end of a sequence
					last_element_to_include = i
					break //end the for loop
				}
			}
			
			for i in stride(from: pucksFromFirebase.count - 1, through: last_element_to_include + 1, by: -1){
				let referenceToShot = referenceToData.child(String(i))
				referenceToShot.removeValue() //removes firebase values one by one
			}
			
			pucksFromFirebase = Array(pucksFromFirebase[0...last_element_to_include])
			dataCounterValue = pucksFromFirebase.count
	}
		
		
		
		
		
		//COREDATA CODE
		/*var tempSeq = tasks
		var newT = [ShotLocations]()
	
		for i in stride(from: fb_tempSeq.count - 2, through: 0, by: -1) { //reverse order loop from 2nd last element
			print(i)
			if(fb_tempSeq[i].shotType != "Pass" && fb_tempSeq[i].shotType != "Skate" && fb_tempSeq[i].shotType != "Same Sequence"){ //if not pass or skate
				fb_newT = Array(fb_tempSeq[0...i]) //make new array from 0-nogoodone
				fb_tempSeq = fb_newT
				break
			}
		} //makes a temperary array with all but the last sequence by iterating backwards until it finds the last outcome
		deleteAllData() //calls delete function
		if fb_newT.count > 0 { //if at least one sequence
			for i in 0...fb_newT.count - 1{
				makeNewShotEntity(x: CGFloat(fb_newT[i].x!), y: CGFloat(fb_newT[i].y!), shotType: fb_newT[i].shotType!, period: fb_newT[i].period!, newSequenceBool: fb_newT[i].newSequenceBool!)
			}
		}
		getData()*/
	}
	
	@IBAction func shotMade(_ sender: UIButton){
		var buttonName = String(describing: sender.titleLabel!.text!)
		//print(buttonName)
		var x = currpos.x
		var y = currpos.y
		var newSequence: Bool
		if(buttonName == "Pass" || buttonName == "Skate" || buttonName == "Same Sequence"){
			newSequence = false
		}
		else{
			newSequence = true
		}
		
		if(	(currpos.x - r/2 > rink.frame.origin.x && currpos.x < rink.frame.width - (r/4) && currpos.y > rink.frame.origin.y && currpos.y < (rink.frame.origin.y + rink.frame.height - (r/4)))	){
			if buttonName == "Same Sequence"{
				makeNewShotEntity(x: screenWidth/2, y: midCreaseH, shotType: "Pass", period: "Period = \(self.title!)", newSequenceBool: newSequence)
				makeNewShotEntity(x: x, y: y, shotType: buttonName, period: "Period = \(self.title!)", newSequenceBool: newSequence)
			}
			else{
				makeNewShotEntity(x: x, y: y, shotType: buttonName, period: "Period = \(self.title!)", newSequenceBool: newSequence)
			}
		}
		
	}
	
	
	@IBAction func showShotProgression(_ sender: UIButton){ //make temp array and when shot post that array to shotsequence
		super.viewDidLoad()
		getData()
		dataCounterValue = pucksFromFirebase.count
		createProgression()
		var seqNum = 0
		var rightSequences = [[ShotLocations]]()
		buttonLastClicked = "\(sender.titleLabel!.text!)"
		for var i in 0...shotSequences.count - 1{
			var tempSequence = shotSequences[i]
			var lastShot = tempSequence.count - 1
			if(tempSequence.count > 0){
				if(tempSequence[lastShot].shotType == sender.titleLabel!.text!){ //if right type of sequence
					rightSequences.append(tempSequence)
				}
			}
		}
		//print(PeriodSelText.text!)
		if(PeriodSelText.text! != "Period = All"){
			rightSequences = sortByPeriod(period: PeriodSelText.text!, shotSequences: rightSequences)
		}
		removeLinesPucks()
		if(rightSequences.count != 0){
			addLine(array: rightSequences, typeWanted: sender.titleLabel!.text!)
		}
	}
	
	//DRAWING FUNCTIONS
	func generateRandomColor() -> UIColor {
		let r : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
		let g : CGFloat = CGFloat(arc4random() % 128) / 256 //
		let b : CGFloat = CGFloat(arc4random() % 128) / 256 //
		
		return UIColor(red: r, green: g, blue: b, alpha: 1)
	}
	
	func addLine(array: [[ShotLocations]], typeWanted: String) {
		if(typeWanted == buttonLastClicked){ //if an old button clicked
			colors.removeAll()
		}
		
		for var i in 0...array.count-1{ //for each sequence within array
			let seqColorUI = generateRandomColor()
			let sequenceColor = seqColorUI.cgColor
			
			colors.append(seqColorUI)
			
			for var j in 0...array[i].count - 1{ //for each one in "i"th sequence
				if(j + 1 <= array[i].count - 1){ //if there is a next puck
					let start = CGPoint(x: CGFloat(array[i][j].x), y: CGFloat(array[i][j].y))
					let end = CGPoint(x: CGFloat(array[i][j+1].x), y: CGFloat(array[i][j+1].y))
					
					let line = CAShapeLayer()
					let linePath = UIBezierPath()
					linePath.move(to: start)
					linePath.addLine(to: end)
					line.path = linePath.cgPath
					line.lineDashPattern = nil
					if(array[i][j+1].shotType! == "Skate"){
						line.lineDashPattern = [12, 4]
					}
					if(j + 2 <= array[i].count - 1){
						if(array[i][j+1].shotType! == "Same Sequence" || array[i][j+2].shotType! == "Same Sequence"){
							line.lineDashPattern = [6, 4]
						}
					}
					
					line.strokeColor = sequenceColor
					line.lineWidth = 4
					line.lineJoin = CAShapeLayerLineJoin.round
					linesBetweenShots.append(line)
					if(linesBetweenShots.count != 0){
						for var i in 0...linesBetweenShots.count-1{
							self.view.layer.addSublayer(linesBetweenShots[i])
						}
					}
				}
				
			}
		}
		addPuck(array: array)
	}
	
	
	
	func addPuck(array: [[ShotLocations]]) {
		for var i in 0...array.count-1{ //for each sequence within array
			var puckNum = 0
			var tintColor = colors[i]
			if array[i].count == 1{
				var puckLoc = CGPoint(x: CGFloat(array[i][0].x), y: CGFloat(array[i][0].y))
				let puckViewTemp = UIImageView(image: UIImage(named: "puck.png")!)
				puckViewTemp.frame = CGRect(x: puckLoc.x - r/2, y: puckLoc.y - r/2, width: r, height: r)
				puckViewTemp.image = puckViewTemp.image!.withRenderingMode(.alwaysTemplate)
				pucksBetweenShots.append(puckViewTemp)
				puckNum+=1
				if(pucksBetweenShots.count != 0){
					for var i in 0...pucksBetweenShots.count-1{
						self.view.addSubview(pucksBetweenShots[i])
					}
				}
			}
			else{
				for var j in 0...array[i].count - 1{ //for each one in "i"th sequence except first spot
					var puckLoc = CGPoint(x: CGFloat(array[i][j].x), y: CGFloat(array[i][j].y))
					var puckViewTemp: UIImageView
					if(j == 0){
						puckViewTemp = UIImageView(image: UIImage(named: "redpuck.png")!)
					}
					else{
						puckViewTemp = UIImageView(image: UIImage(named: "puck.png")!)
						puckViewTemp.image = puckViewTemp.image!.withRenderingMode(.alwaysTemplate)
						puckViewTemp.tintColor = tintColor
					}
					puckViewTemp.frame = CGRect(x: puckLoc.x - r/2, y: puckLoc.y - r/2, width: r, height: r)
					pucksBetweenShots.append(puckViewTemp)
					puckNum+=1
					if(pucksBetweenShots.count != 0){
						for var i in 0...pucksBetweenShots.count-1{
							self.view.addSubview(pucksBetweenShots[i])
						}
					}
				}
			}
		}
	}
	
	func removeLinesPucks(){
		if(linesBetweenShots.count != 0){ //clears lines
			for var i in 0...linesBetweenShots.count-1{
				linesBetweenShots[i].removeFromSuperlayer()
			}
			linesBetweenShots = []
		}
		if(pucksBetweenShots.count != 0){ //clears lines
			for var i in 0...pucksBetweenShots.count-1{
				pucksBetweenShots[i].removeFromSuperview()
			}
			pucksBetweenShots = []
		}
	}
	
	
	func drawPuck(pos: CGPoint){
		pView.frame = CGRect(x: pos.x, y: pos.y, width: r, height: r)
		view.addSubview(pView)
	}
	
	//PERIOD SELECTION
	@IBAction func handleSelection(_ sender: UIButton) {
		animate_buttonSlide()
	}
	
	func animate_buttonSlide(){
		periodButtons.forEach { (button) in UIView.animate(withDuration: 0.3, animations: {
			button.titleLabel!.text = " "
			button.isHidden = !button.isHidden
			self.view.layoutIfNeeded()
		})
		}
	}
	
	@IBAction func periodSelected(_ sender: UIButton) {
		guard let title = sender.currentTitle, let period = Periods(rawValue: title) else {
			return
		}
		
		switch period {
		case .p1:
			PeriodSelText.text = "Period = Period 1"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: shotSequences).count)"
			totalShots.text = "Total Shots = \(shotSequences.count)"
		case .p2:
			PeriodSelText.text = "Period = Period 2"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: shotSequences).count)"
			totalShots.text = "Total Shots = \(shotSequences.count)"
		case .p3:
			PeriodSelText.text = "Period = Period 3"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: shotSequences).count)"
			totalShots.text = "Total Shots = \(shotSequences.count)"
		case .ot:
			PeriodSelText.text = "Period = Overtime"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: shotSequences).count)"
			totalShots.text = "Total Shots = \(shotSequences.count)"
		case .all:
			PeriodSelText.text = "Period = All"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = All"
			totalShots.text = "Total Shots = \(shotSequences.count)"
		default:
			print("Failed to Isolate Period")
		}
	}
	
	//PROGRESSION MODIFY
	func makeNewShotEntity(x: CGFloat, y: CGFloat, shotType: String, period: String, newSequenceBool: Bool ){ //unsure if this works
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let tempGame = PuckModel(x_: x, y_: y, sT_: shotType, p_: period, nSB_: newSequenceBool)
		let gameToBeSaved = tempGame.toAnyObject()
		let counterString = String(pucksFromFirebase.count)
		let gameItemRef = self.ref.child("games").child((Auth.auth().currentUser?.uid)!).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(counterString)
		
		gameItemRef.setValue(gameToBeSaved)
		pucksFromFirebase.append(tempGame)
		
		
		/*let task = ShotLocations(context: managedContext)
		task.x = Float(x)
		task.y = Float(y)
		task.shotType = shotType
		task.period = period
		task.newSequence = newSequenceBool
		tasks.append(task)
		(UIApplication.shared.delegate as! AppDelegate).saveContext()*/
	}
	
	func createProgression(){
		
		shotSequences = [[]]
		var seqNum = 0
		var lastCurrent = 0
		if(tasks.count > 0){
			for var current in 0...tasks.count - 1{
				var tempshot = tasks[current]
				let temptype = tempshot.shotType!
				let tempNewSequence = tempshot.newSequence
				if temptype != "Pass" && temptype != "Skate"  && temptype != "Same Sequence" && tempNewSequence == true { //if not pass/skate and not new sequence
					var tempSequence = [ShotLocations]()
					for var temp in lastCurrent...current{
						tempSequence.append(tasks[temp])
					}
					if(seqNum == 0){ //if no prior sequence edit "0"th element
						shotSequences[0] = tempSequence
					}
					else{ //if prior sequence append new sequence at end
						shotSequences.append(tempSequence)
					}
					lastCurrent = current + 1;
					seqNum += 1
				}
			}
		}
	}
	
	func sortByPeriod(period: String, shotSequences: [[ShotLocations]]) -> [[ShotLocations]]{
		var periodShots = [[ShotLocations]]()
		super.viewDidLoad()
		getData()
		createProgression()
		if(shotSequences.count > 0){
			var seqNum = 0
			for var i in 0...shotSequences.count - 1{
				var tempSequence = shotSequences[i]
				var lastShot = tempSequence.count - 1;
				if(tempSequence.count > 0){
					if(period != "Period = All"){
						if(tempSequence[lastShot].period == period){ //if right type of period
							periodShots.append(tempSequence)
						}
					}
				}
			}
			removeLinesPucks()
		}
		return periodShots
	}
	
	func sP(period: String, shotSequences: [[PuckModel]]) -> [[PuckModel]]{
		var periodShots = [[PuckModel]]()
		super.viewDidLoad()
		getData()
		createProgression()
		if shotSequences.count > 0 {
			for i in 0...shotSequences.count - 1{
				let tempSequence = shotSequences[i]
				let lastShot = tempSequence.count - 1
				if tempSequence.count > 0{
					if period != "Period = All" && tempSequence[lastShot].period == period{
						periodShots.append(tempSequence)
					}
				}
			}
		}
		return periodShots
	}
	
	//THESE ARE THE MAIN UI FUNCTIONS//
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if(self.title! != "Final Shots"){ //if not show shot scene
				let position = touch.location(in: self.view)
				let posImg = CGPoint(x: position.x - r/2, y: position.y - r/2)
				currpos = posImg
				if(	(position.x - r/2 > rink.frame.origin.x && position.x < rink.frame.width - (r/4) && position.y > rink.frame.origin.y && position.y < (rink.frame.origin.y + rink.frame.height - (r/4)))	){
					drawPuck(pos: posImg)
				}
			}
		}
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		
		r = (10/414)*screenWidth
		getData()
		dataCounterValue = pucksFromFirebase.count
		print("Tasks count = \(tasks.count)")
		print("FB Data Count = \(dataCounterValue)")
		print("Signed in as \(Auth.auth().currentUser!.email)")
		
		removeLinesPucks()
		
		linesBetweenShots = [CAShapeLayer]()
		pucksBetweenShots = [UIImageView]()
		pView.removeFromSuperview()
		print("Game: \(gameToBeWorkingOn.gameFBLabel!)")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
}


