//
//  ViewController.swift
//  Shot Tracker
//
//  Created by __ on 9/25/17.
//  Copyright © 2017 __. All rights reserved.
//

import UIKit

class DistanceController: UIViewController {
    @IBOutlet weak var rink: UIImageView!
	@IBOutlet weak var distNet: UILabel!
	@IBOutlet weak var reqHeight: UILabel!
	@IBOutlet weak var reqWidth: UILabel!
	@IBOutlet weak var wDec: UILabel!
	@IBOutlet weak var hDec: UILabel!
	@IBOutlet weak var creaseDims: UILabel!
	let pView = UIImageView(image: UIImage(named: "puck.png"))
	let gView = UIImageView(image: UIImage(named: "goaliesq.png"))
	let screenWidth = UIScreen.main.bounds.width
	let screenHeight = UIScreen.main.bounds.height
	let gLineH = (985/1112)*UIScreen.main.bounds.height
    var puckPos: CGPoint = CGPoint(x: 0, y: 0)
	var xCoord: CGFloat = 0
	var yCoord: CGFloat = 0
	var goalpuck: Int = 1 //determines whether goalie or puck is being placed
	var tWidth: CGFloat = 0
	var tHeight: CGFloat = 0
    var gWidth: CGFloat = 0
    var gHeight: CGFloat = 0
	var shotdist: CGFloat = 0
	var goaliedist: CGFloat = 0
	var r: CGFloat = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self.view)
			if(goalpuck == 1){ //1 means puck, -1 means goalie
				let posImg = CGPoint(x: position.x - r/2, y: position.y - r/2)
				if(position.x - r/2 > rink.frame.origin.x && position.x < rink.frame.width - r/2 && position.y - r/4 > rink.frame.origin.y && position.y < (rink.frame.origin.y + rink.frame.height - r/4)){
					drawPuck(pos: posImg)
                    puckPos = position
					let dist_ = Double(String(format: "%.0f", shotdistance(pos: position)))
					shotdist = CGFloat(dist_!)
					distNet.text = "Shot Length: " + String(describing: shotdist) + "ft"
                    goalpuck *= -1
				}
			}
			else{
				let posImg = CGPoint(x: position.x - 5, y: position.y - 5)
				if(position.x - r/2 > rink.frame.origin.x && position.x < rink.frame.width - r/4 && position.y - r/2 > rink.frame.origin.y && position.y < (rink.frame.origin.y + rink.frame.height - r/4)){
					drawGoalie(pos: posImg)
					let dist_ = Double(String(format: "%.1f", goaliedist(pos: position)))
					goaliedist = CGFloat(dist_!)
					goalpuck *= -1
				}
			}
            goalienums(pos: puckPos)
		}
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		r = (7.5/414)*screenWidth
        let pName = "puck.png"
        let puck = UIImage(named: pName)
        let pView = UIImageView(image: puck!)
		let gName = "goaliesq.png"
		let goalie = UIImage(named: "goaliesq.png")
		let gView = UIImageView(image: goalie!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func drawPuck(pos: CGPoint){
        print(rink.frame.minX, rink.frame.minY)
        print(screenHeight)
        pView.removeFromSuperview()
        pView.frame = CGRect(x: pos.x, y: pos.y, width: r, height: r)
        view.addSubview(pView)
    }
	func drawGoalie(pos: CGPoint){
		gView.removeFromSuperview()
		gView.frame = CGRect(x: pos.x, y: pos.y, width: 1.5*r, height: 1.5*r)
		view.addSubview(gView)
	}
	
	func shotdistance(pos: CGPoint) -> CGFloat{
		xCoord = pos.x
		yCoord = pos.y
		print(pos.x, pos.y)
		var hconstant: CGFloat = 0
		let wconstant: CGFloat = 86 / screenWidth
		if(pos.y >= gLineH){hconstant = 120 / rink.frame.maxY}
		else {hconstant = 65 / (gLineH - rink.frame.minY)}
		tWidth = abs(xCoord - screenWidth/2) * wconstant
		tHeight = abs(gLineH - yCoord) * hconstant
		let dist = (sqrt((tWidth * tWidth) + (tHeight * tHeight)))
	
		return dist
	}
	
    func goaliedist(pos: CGPoint) -> CGFloat{
        xCoord = pos.x
        yCoord = pos.y
        var hconstant: CGFloat = 0
        let wconstant: CGFloat = 85 / screenWidth
        if(pos.y >= gLineH){hconstant = 120 / rink.frame.maxY}
        else {hconstant = 64 / (gLineH - rink.frame.minY)}
        gWidth = abs(xCoord - screenWidth/2) * wconstant
        gHeight = abs(gLineH - yCoord) * hconstant
        let dist: CGFloat = (sqrt((gWidth * gWidth) + (gHeight * gHeight)))
        
        return dist
    }
	
    
    func goalienums(pos: CGPoint){
		print("TWidth: \(tWidth) THeight: \(tHeight) goalieDist: \(goaliedist)")
		let wunround = 6*cos(atan(tWidth/tHeight))
		var wRound = String(format: "%.1f", wunround) //width availible crease
        if(pos.y >= gLineH){creaseDims.text = "W of Crease: 0.0ft, H Visible Net: 4.0ft"}
		else{creaseDims.text = "W Visible Net: " + String(describing: wRound) + "ft, H Visible Net: 4.0ft"}
		
		
		let gblockw = CGFloat(Double(wRound)!*Double(shotdist-goaliedist))/(CGFloat(shotdist)-3*sin(atan(tWidth/tHeight)))
		let gbwRound = String(format: "%.1f", gblockw) //req blocking width
		reqWidth.text = "Required goalie blocking width: " + String(describing: gbwRound) + "ft"
		
		let gblockh = CGFloat(4*(shotdist - goaliedist)/shotdist)
		let gbhRound = String(format: "%.1f", gblockh) //req blocking height
		reqHeight.text = "Required goalie blocking height: " + String(describing: gbhRound) + "ft"
		
		let gwDec = (wunround - gblockw) / (CGFloat(goaliedist) - 3*sin(atan(tWidth/tHeight)))*12
		let wDecRound = String(format: "%.1f", gwDec)
		wDec.text = "Goal width decrease per foot: " + wDecRound + "in"
		
		let ghDec: CGFloat = (4-4*(shotdist - 1)/shotdist)*12
		let hDecRound = String(format: "%.1f", ghDec)
		hDec.text = "Goal height decrease per foot: " + hDecRound + "in"
	}
		
}
