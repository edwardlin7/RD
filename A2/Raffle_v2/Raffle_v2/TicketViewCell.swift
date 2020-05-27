//
//  TicketViewCell.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketViewCell: UITableViewCell {

    @IBOutlet weak var ticketNum: UILabel!
    @IBOutlet weak var customer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
