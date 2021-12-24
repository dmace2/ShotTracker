//
//  PuckModel.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 10/19/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PuckModel{
	var period: String?
	var shotType: String?
	var x: CGFloat?
	var y: CGFloat?
	var newSequenceBool: Bool?
	
	init(x_: CGFloat, y_: CGFloat, sT_: String, p_: String, nSB_: Bool) {
		x = x_
		y = y_
		shotType = sT_
		period = p_
		newSequenceBool = nSB_
	}
	
	func toAnyObject() -> Any {
		return [
			"x": x!,
			"y": y!,
			"shotType": shotType!,
			"period": period!,
			"newSequenceBool": newSequenceBool!
		]
	}
}


