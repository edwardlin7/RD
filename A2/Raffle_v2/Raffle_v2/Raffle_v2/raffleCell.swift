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
    
    var cellDelegate:TableViewRaffle?
    var index:IndexPath?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func raffleEditBtn(_ sender: Any) {
        cellDelegate?.onClickCell(index: (index?.row)!)
    }
    
}
