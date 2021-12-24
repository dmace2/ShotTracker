//
//  GameCellTableViewCell.swift
//  
//
//  Created by Dylan Mace on 10/16/18.
//

import UIKit

class GameCellTableViewCell: UITableViewCell {
	@IBOutlet weak var nicknameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet var imageToDisplay: UIImageView! = UIImageView(image: UIImage(named: "puck.png")!)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
