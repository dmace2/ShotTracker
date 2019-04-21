//
//  TabBarViewController.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 10/17/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
	var gameToEdit: GameModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		print(gameToEdit.gameFBLabel!)
		let viewControllerArray = self.viewControllers
		for i in 0...viewControllerArray!.count - 1{
			let viewControllerTemp = viewControllerArray![i] as! PuckTrackerController
			viewControllerTemp.gameToBeWorkingOn = gameToEdit
		}

        // Do any additional setup after loading the view.
    }
}
	
	
	class NewTabBarViewController: UITabBarController {
		var gameToEdit: GameModel!
		
		override func viewDidLoad() {
			super.viewDidLoad()
			print(gameToEdit.gameFBLabel!)
			let viewControllerArray = self.viewControllers
			for i in 0...viewControllerArray!.count - 1{
				let viewControllerTemp = viewControllerArray![i] as! FBShotTrackerViewController
				viewControllerTemp.gameToBeWorkingOn = gameToEdit
			}
			
			// Do any additional setup after loading the view.
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
