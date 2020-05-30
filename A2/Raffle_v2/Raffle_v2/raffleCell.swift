//
//  raffleCell.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/2.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

protocol TableViewRaffle {
    func onClickCell(index:Int)
}

class raffleCell: UITableViewCell {

    @IBOutlet var raffleCover: UIImageView!
    @IBOutlet var raffleName: UILabel!
    @IBOutlet weak var raffleType: UILabel!
    @IBOutlet weak var winner: UILabel!
    @IBOutlet weak var winnerLabel:UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var customerName: UILabel!
    
    var cellDelegate:TableViewRaffle?
    var index:IndexPath?
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // Debug function to see spec of a selected cell
    @IBAction func raffleEditBtn(_ sender: Any) {
        cellDelegate?.onClickCell(index: (index?.row)!)
    }
    
}
