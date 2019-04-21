//
//  GameTableViewCell.swift
//  Shot Tracker!
//
//  Created by Dylan Mace on 9/25/18.
//  Copyright © 2018 Dylan Mace. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var gameDateLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
