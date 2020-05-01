//
//  RaffleUITableViewCell.swift
//  Raffle_v1
//
//  Created by cliu18 on 2020/5/1.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class RaffleUITableViewCell: UITableViewCell {

    @IBOutlet var RaffleName: UILabel!
    @IBOutlet var raffleDescription: UILabel!
    @IBOutlet var raffleCover: UILabel!
    @IBOutlet var raffleAmount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
