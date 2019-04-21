//
//  FBShotTrackerViewController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 10/28/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit
import Firebase
import CoreData

extension UIBezierPath {
	
	static func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath { //makes an arrow
		let length = hypot(end.x - start.x, end.y - start.y)
		let tailLength = length - headLength
		
		func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
		let points: [CGPoint] = [
			p(0, tailWidth / 2),
			p(tailLength, tailWidth / 2),
			p(tailLength, headWidth / 2),
			p(length, 0),
			p(tailLength, -headWidth / 2),
			p(tailLength, -tailWidth / 2),
			p(0, -tailWidth / 2)
		]
		
		let cosine = (end.x - start.x) / length
		let sine = (end.y - start.y) / length
		let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
		
		let path = CGMutablePath()
		path.addLines(between: points, transform: transform)
		path.closeSubpath()
		
		return self.init(cgPath: path)
	}
	
}


class FBShotTrackerViewController: UIViewController {
	@IBOutlet weak var rink: UIImageView!
	
	
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
	
	//HERE STARTS THE FUNCTIONS
	func translateXYToRelative(x_: CGFloat, y_: CGFloat) -> CGPoint{
		let oldPoint = CGPoint(x: x_, y: y_)
		var newScaledPoint: CGPoint!
		let xScaled = (oldPoint.x - rink.frame.minX)/rink.frame.width
		let yScaled = (oldPoint.y - rink.frame.minY)/rink.frame.height //gives percentage width and height into the rink from top left corner
		
		newScaledPoint = CGPoint(x: xScaled, y: yScaled)
		
		return newScaledPoint
	}
	
	func translateXYToAbsolute(x_: CGFloat, y_: CGFloat) -> CGPoint{
		let oldPoint = CGPoint(x: x_, y: y_)
		var newScaledPoint: CGPoint!
		let xAbs = oldPoint.x * rink.frame.width + rink.frame.minX
		let yAbs = oldPoint.y * rink.frame.height + rink.frame.minY
		newScaledPoint = CGPoint(x: xAbs, y: yAbs)
		return newScaledPoint
	}
	
	func createAlert(notifTitle: String, notifMessage: String){
		let alert = UIAlertController(title: notifTitle, message: notifMessage, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
	
	
	
	//FIREBASE DATA MODYFYING FUNCTIONS
	func getData() {
		ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").observe(DataEventType.value, with: {snapshot in
			if snapshot.childrenCount > 0{
				self.pucksFromFirebase.removeAll()
				
				for games in snapshot.children.allObjects as! [DataSnapshot] {
					let gameObject = games.value as? [String: Any]
					//print(gameObject)
					let gameX = gameObject?["x"] as? CGFloat
					//print(gameX)
					
					
					let gameY = gameObject?["y"] as? CGFloat
					
					let gameShotType = gameObject?["shotType"]! as? String
					let gamePeriod = gameObject?["period"] as? String
					let gameNewSeqBool = gameObject?["newSequenceBool"] as? Bool
					
					
					let game = PuckModel(x_: gameX! , y_: gameY! , sT_: gameShotType! , p_: gamePeriod! , nSB_: gameNewSeqBool! )
					
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
	}
	
	//BUTTON CLICK FUNCTIONS
	@IBAction func undoShot(_ sender: UIButton) {
		if pucksFromFirebase.count > 0{
			//let tempShots = pucksFromFirebase[0...pucksFromFirebase.count - 2]
			let referenceToChild = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count-1))
			referenceToChild.removeValue() //remove last puck from firebase
			pucksFromFirebase.removeLast() //remove locally
			dataCounterValue = pucksFromFirebase.count //fix data counter value for data saving
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
	}
	
	//CHOOSE LOCATION AND SAVE SHOT
	func drawPuck(pos: CGPoint){
		pView.frame = CGRect(x: pos.x, y: pos.y, width: r, height: r)
		view.addSubview(pView)
	}
	
	@IBAction func shotButtonClicked(_ sender: UIButton){
		let buttonName = String(describing: sender.titleLabel!.text!)
		//print(buttonName)
		let x = currpos.x
		let y = currpos.y
		var newSequence: Bool
		if(buttonName == "Pass" || buttonName == "Skate" || buttonName == "Same Sequence"){
			newSequence = false
		}
		else{
			newSequence = true
		}
		
		
		if(	(currpos.x - r/2 > rink.frame.origin.x && currpos.x < rink.frame.width - (r/4) && currpos.y > rink.frame.origin.y && currpos.y < (rink.frame.origin.y + rink.frame.height - (r/4)))	){
			let newXY = translateXYToRelative(x_: x, y_: y) //translates to relative coordinate system for use on all devices
			if buttonName == "Same Sequence"{
				let translatedCreasePoint = translateXYToRelative(x_: screenWidth/2, y_: midCreaseH)
				let childRef = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count - 1)) //this is a reference to the last element created
				childRef.removeValue() //removes the element with pass
				pucksFromFirebase.removeLast() //removes last puck from local array
				makeNewShotEntity(x: translatedCreasePoint.x, y: translatedCreasePoint.y, shotType: "Same Sequence", period: "Period = \(self.title!)", newSequenceBool: newSequence) //new element in middle of crease
				//makeNewShotEntity(x: newXY.x, y: newXY.y, shotType: buttonName, period: "Period = \(self.title!)", newSequenceBool: newSequence) //new element at location of user click
			}
			/*let childRef = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count - 1))
			childRef.removeValue()*/
			//pucksFromFirebase.removeLast()
			//	pucksFromFirebase.append(PuckModel(x_: newXY.x, y_: newXY.y, sT_: buttonName, p_: "Period = \(String(describing: self.title))", nSB_: newSequence)) //if already something to be changed and the click is within the region of error, edit firebase, local copy
			makeNewShotEntity(x: newXY.x, y: newXY.y, shotType: buttonName, period: "Period = \(self.title!)", newSequenceBool: newSequence) //new element at location of user click
		}
		
	}
	
	func makeNewShotEntity(x: CGFloat, y: CGFloat, shotType: String, period: String, newSequenceBool: Bool ){ //unsure if this works
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.persistentContainer.viewContext
		let tempGame = PuckModel(x_: x, y_: y, sT_: shotType, p_: period, nSB_: newSequenceBool)
		let gameToBeSaved = tempGame.toAnyObject()
		let counterString = String(pucksFromFirebase.count)
		let gameItemRef = self.ref.child("games").child((Auth.auth().currentUser?.uid)!).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(counterString)
		
		gameItemRef.setValue(gameToBeSaved)
		pucksFromFirebase.append(tempGame)
	}
	
	//SORT THE DATA
	@IBAction func showShotProgression(_ sender: UIButton){
		getData()
		dataCounterValue = pucksFromFirebase.count
		createProgressionsNoType()
		//		print(sequencesFromFirebase)
		var rightSequences = [[PuckModel]]()
		buttonLastClicked = "\(sender.titleLabel!.text!)"
		for i in 0...sequencesFromFirebase.count - 1{
			var tempSequence = sequencesFromFirebase[i]
			let lastShot = tempSequence.count - 1
			if(tempSequence.count > 0){
				if(tempSequence[lastShot].shotType == sender.titleLabel!.text!){ //if right type of sequence
					rightSequences.append(tempSequence)
				}
			}
		}
		//
		if(PeriodSelText.text! != "Period = All"){
			rightSequences = sortByPeriod(period: PeriodSelText.text!, shotSequences: rightSequences)
		}
		//		print("Init: \(sequencesFromFirebase)")
		//		print("Right: \(rightSequences)")
		removeLinesPucks()
		if(rightSequences.count != 0){
			addLine(array: rightSequences, typeWanted: sender.titleLabel!.text!)
		}
	}
	
	func createProgressionsNoType(){
		sequencesFromFirebase = [[]]
		var seqNum = 0
		var lastCurrent = 0
		if(pucksFromFirebase.count > 0){
			for current in 0...pucksFromFirebase.count - 1{
				let tempshot = pucksFromFirebase[current]
				let temptype = tempshot.shotType!
				let tempNewSequence = tempshot.newSequenceBool
				if temptype != "Pass" && temptype != "Skate"  && temptype != "Same Sequence" && tempNewSequence == true { //if not pass/skate and not new sequence
					var tempSequence = [PuckModel]()
					for temp in lastCurrent...current{
						tempSequence.append(pucksFromFirebase[temp])
					}
					if(seqNum == 0){ //if no prior sequence edit "0"th element
						sequencesFromFirebase[0] = tempSequence
					}
					else{ //if prior sequence append new sequence at end
						sequencesFromFirebase.append(tempSequence)
					}
					lastCurrent = current + 1;
					seqNum += 1
				}
			}
		}
	}
	
	func sortByPeriod(period: String, shotSequences: [[PuckModel]]) -> [[PuckModel]]{
		var periodShots = [[PuckModel]]()
		super.viewDidLoad()
		getData()
		createProgressionsNoType()
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
	
	func removeLinesPucks(){
		if(linesBetweenShots.count != 0){ //clears lines
			for i in 0...linesBetweenShots.count-1{
				linesBetweenShots[i].removeFromSuperlayer()
			}
			linesBetweenShots = []
		}
		if(pucksBetweenShots.count != 0){ //clears lines
			for i in 0...pucksBetweenShots.count-1{
				pucksBetweenShots[i].removeFromSuperview()
			}
			pucksBetweenShots = []
		}
		
	}
	
	func generateRandomColor() -> UIColor {
		let r : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
		let g : CGFloat = CGFloat(arc4random() % 128) / 256 //
		let b : CGFloat = CGFloat(arc4random() % 128) / 256 //
		
		return UIColor(red: r, green: g, blue: b, alpha: 1)
	}
	
	
	func addLine(array: [[PuckModel]], typeWanted: String){
		if(typeWanted == buttonLastClicked){ //if an old button clicked
			colors.removeAll()
		}
		
		
		for i in 0...array.count-1{ //for each sequence within array
			let seqColorUI = generateRandomColor()
			let sequenceColor = seqColorUI.cgColor
			
			colors.append(seqColorUI)
			
			for j in 0...array[i].count - 1{ //for each one in "i"th sequence
				if(j + 1 <= array[i].count - 1){ //if there is a next puck
					let absInitPoint = translateXYToAbsolute(x_: CGFloat(array[i][j].x!), y_: CGFloat(array[i][j].y!))
					let absEndPoint = translateXYToAbsolute(x_: CGFloat(array[i][j+1].x!), y_: CGFloat(array[i][j+1].y!))
					let start = absInitPoint//CGPoint(x: CGFloat(array[i][j].x!), y: CGFloat(array[i][j].y!))
					let end = absEndPoint//CGPoint(x: CGFloat(array[i][j+1].x!), y: CGFloat(array[i][j+1].y!)) //this is the point of the puck in front of it
					
					let line = CAShapeLayer()
					let linePath = UIBezierPath()
					linePath.move(to: start)
					linePath.addLine(to: end)
					line.path = linePath.cgPath
					let midPoint = CGPoint(x: start.x + (end.x - start.x)/2, y: start.y + (end.y - start.y)/2)
					let arrow = UIBezierPath.arrow(from: start, to: midPoint, tailWidth: 0, headWidth: 24, headLength: 12)
					let secondLine = UIBezierPath.arrow(from: midPoint, to: end, tailWidth: 0, headWidth: 0, headLength: 0)
					arrow.append(secondLine)
					line.path = arrow.cgPath
					line.lineDashPattern = nil
					if(array[i][j+1].shotType! == "Skate"){
						line.lineDashPattern = [12, 4]
					}
					else if(j + 1 <= array[i].count - 1){
						if(array[i][j+1].shotType! == "Same Sequence"){
							line.lineDashPattern = [6, 4, 2, 4]
						}
					}
					
					line.strokeColor = sequenceColor
					line.fillColor = UIColor.clear.cgColor
					line.lineWidth = 4
					//line.lineJoin = CAShapeLayerLineJoin.round
					linesBetweenShots.append(line)
					if(linesBetweenShots.count != 0){
						for i in 0...linesBetweenShots.count-1{
							self.view.layer.addSublayer(linesBetweenShots[i])
						}
					}
				}
				
			}
		}
		addPuck(array: array)
	}
	
	func addPuck(array: [[PuckModel]]){
		for i in 0...array.count-1{ //for each sequence within array
			var puckNum = 0
			let tintColor = colors[i]
			if array[i].count == 1{
				let translatedPoint = translateXYToAbsolute(x_: CGFloat(array[i][0].x!), y_: CGFloat(array[i][0].y!))
				let puckLoc = translatedPoint //CGPoint(x: CGFloat(array[i][0].x!), y: CGFloat(array[i][0].y!))
				let puckViewTemp = UIImageView(image: UIImage(named: "puck.png")!)
				puckViewTemp.frame = CGRect(x: puckLoc.x - r/2, y: puckLoc.y - r/2, width: r, height: r)
				puckViewTemp.image = puckViewTemp.image!.withRenderingMode(.alwaysTemplate)
				pucksBetweenShots.append(puckViewTemp)
				puckNum+=1
				if(pucksBetweenShots.count != 0){
					for i in 0...pucksBetweenShots.count-1{
						self.view.addSubview(pucksBetweenShots[i])
					}
				}
			}
			else{
				for j in 0...array[i].count - 1{ //for each one in "i"th sequence except first spot
					let translatedPoint = translateXYToAbsolute(x_: CGFloat(array[i][j].x!), y_: CGFloat(array[i][j].y!))
					let puckLoc = translatedPoint //CGPoint(x: CGFloat(array[i][0].x!), y: CGFloat(array[i][0].y!))
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
						for i in 0...pucksBetweenShots.count-1{
							self.view.addSubview(pucksBetweenShots[i])
						}
					}
				}
			}
		}
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
		removeLinesPucks()
		
		switch period {
		case .p1:
			PeriodSelText.text = "Period = Period 1"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: sequencesFromFirebase).count)"
			totalShots.text = "Total Shots = \(sequencesFromFirebase.count)"
		case .p2:
			PeriodSelText.text = "Period = Period 2"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: sequencesFromFirebase).count)"
			totalShots.text = "Total Shots = \(sequencesFromFirebase.count)"
		case .p3:
			PeriodSelText.text = "Period = Period 3"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: sequencesFromFirebase).count)"
			totalShots.text = "Total Shots = \(sequencesFromFirebase.count)"
		case .ot:
			PeriodSelText.text = "Period = Overtime"
			animate_buttonSlide()
			getData()
			perShots.text = "Shots Per This Period = \(sortByPeriod(period: PeriodSelText.text!, shotSequences: sequencesFromFirebase).count)"
			totalShots.text = "Total Shots = \(sequencesFromFirebase.count)"
		case .all:
			PeriodSelText.text = "Period = All"
			animate_buttonSlide()
			getData()
			removeLinesPucks()
			perShots.text = "Shots Per This Period = All"
			totalShots.text = "Total Shots = \(sequencesFromFirebase.count)"
		default:
			print("Failed to Isolate Period")
		}
	}
	
	
	//THESE ARE DEFAULT SWIFT FUNCTIONS
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if(self.title! != "Final Shots"){ //if not show shot scene
				let position = touch.location(in: self.view)
				let posImg = CGPoint(x: position.x - r/2, y: position.y - r/2)
				currpos = posImg
				if(	(position.x - r/2 > rink.frame.origin.x && position.x < rink.frame.width - (r/4) && position.y > rink.frame.origin.y && position.y < (rink.frame.origin.y + rink.frame.height - (r/4)))	){
					
					var lastAbsolute: CGPoint = CGPoint(x: 0, y: 0 )
					var isToBeChangedToSkate = false
					
					if pucksFromFirebase.count > 0 {
						let lastElement = pucksFromFirebase.last!
						lastAbsolute = translateXYToAbsolute(x_: lastElement.x!, y_: lastElement.y!)
						if (posImg.x > lastAbsolute.x - 40) && (posImg.x < lastAbsolute.x + 40) && (posImg.y > lastAbsolute.y - 40) && (posImg.y < lastAbsolute.y + 40) && "Period = \(self.title!)" == lastElement.period!{
							print("within boundaries")
							isToBeChangedToSkate = true
							
						}
					}
					if isToBeChangedToSkate == true{
						//edit last element within firebase
						let lastRef = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count - 1))
						lastRef.updateChildValues(["shotType" : "Skate"])
						//edit last element in array with new one of type skate
						pucksFromFirebase[pucksFromFirebase.count - 1].shotType = "Skate"
						self.createAlert(notifTitle: "Changed to Skate", notifMessage: "puck changed from pass to skate.")
						drawPuck(pos: lastAbsolute)
					}
					else {
						//make a new entity with type pass
						let transPoint = translateXYToRelative(x_: posImg.x, y_: posImg.y) //translates to relative coordinate system
						makeNewShotEntity(x: transPoint.x, y: transPoint.y, shotType: "Pass", period: "Period = \(self.title!)", newSequenceBool: false)
						drawPuck(pos: posImg)
						
					}
					/*
					1. check the last element x,y
					2. check against new x,y
					if within 40 each way, change last element to skate
					otherwise pass
					*/
					
					
					
					/*var isToBeReplacedBySkate = false
					
					if pucksFromFirebase.count > 0{
					print("foop")
					let lastPuck = pucksFromFirebase.last!
					let translatedLastPoint = translateXYToAbsolute(x_: lastPuck.x!, y_: lastPuck.y!)
					if (currpos.x > translatedLastPoint.x - 40 && currpos.x < translatedLastPoint.x + 40) && (currpos.y > translatedLastPoint.y - 40 && currpos.y < translatedLastPoint.y + 40) && lastPuck.shotType! == "Pass"{
					print("within region of error of the last  puck")
					isToBeReplacedBySkate = true
					let childRef = ref.child("games").child(Auth.auth().currentUser!.uid).child(gameToBeWorkingOn.gameFBLabel!).child("data").child(String(pucksFromFirebase.count - 1))
					childRef.updateChildValues(["shotType": "Skate"])
					pucksFromFirebase[pucksFromFirebase.count - 1] = PuckModel(x_: lastPuck.x!, y_: lastPuck.y!, sT_: "Skate", p_: lastPuck.period!, nSB_: lastPuck.newSequenceBool!) //if already something to be changed and the click is within the region of error, edit firebase, local copy
					self.createAlert(notifTitle: "Changed to Skate", notifMessage: "puck changed from pass to skate.")
					}
					}
					
					if isToBeReplacedBySkate == false { //if the puck was not replaced
					print("foo")
					let translatedToRelative = translateXYToRelative(x_: currpos.x, y_: currpos.y)
					makeNewShotEntity(x: translatedToRelative.x, y: translatedToRelative.y, shotType: "Pass", period: "Period = \(self.title!)", newSequenceBool: false)
					}*/
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
		print("FB Data Count = \(String(describing: dataCounterValue))")
		print("Signed in as \(String(describing: Auth.auth().currentUser!.email))")
		
		
		linesBetweenShots = [CAShapeLayer]()
		pucksBetweenShots = [UIImageView]()
		pView.removeFromSuperview()
		print("Game: \(gameToBeWorkingOn.gameFBLabel!)")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		removeLinesPucks()
		pView.removeFromSuperview()
	}
	
	
	
}
