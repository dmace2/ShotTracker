//
//  GameModel.swift
//  
//
//  Created by Dylan Mace on 10/16/18.
//

import Foundation

class GameModel{
    var gameDate: String?
    var gameNickname: String?
    var data: String?
	var gameFBLabel: String?
    
	init(gameDate:String?, gameNickname: String?, data: String?, gameFBLabel: String?){
        self.gameDate = gameDate
        self.gameNickname = gameNickname
        self.data = data
		self.gameFBLabel = gameFBLabel
    }
	
	func toAnyObject() -> Any {
		return [
			"gameNickname": gameNickname,
			"gameDate": gameDate,
			"data": data,
			"gameFBLabel": gameFBLabel
		]
	}
}
