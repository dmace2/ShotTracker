//
//  ButtonClass.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 5/30/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import Foundation
import UIKit

public class custoButton: UIButton {
	
	
	required public init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		//self.titleLabel?.textColor = UIColor.black
		self.clipsToBounds = true
		self.layer.cornerRadius = (30/376)*self.frame.height
		if #available(iOS 11.0, *) {
			if(self.titleLabel!.text ==  "Overtime"){
				self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
			}
			else if (self.titleLabel!.text == "Period 2" || self.titleLabel!.text == "Period 3" || self.titleLabel!.text == "Period 1"){
				self.layer.maskedCorners = []
			}
			else if(self.titleLabel!.text ==  "All"){
				self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			}
		} else {
			//fall back
		}
		//self.layer.cornerRadius = (10/376)*self.frame.width
	}
	
}
