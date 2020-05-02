//
//  editRaffleController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/3.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class editRaffleController: UIViewController {
    @IBOutlet var editName: UITextField!
    
    @IBOutlet var editDescription: UITextView!
    
    @IBOutlet var editCover: UIImageView!
    
    @IBOutlet var editCoverBtn: UIButton!
    
    @IBOutlet var editPrice: UITextField!
    
    @IBOutlet var soldAmount: UILabel!
    
    @IBOutlet var editTotal: UITextField!
    
    var raffle:Raffle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let displayRaffle = raffle{
            
            let viewController = ViewController()
            
            editName.text = displayRaffle.name
            editDescription.text = displayRaffle.description
            editCover.image = viewController.decodeImage(imageBase64: displayRaffle.cover )
            editPrice.text = String(displayRaffle.price)
            soldAmount.text = String(displayRaffle.sold_amount)
            editTotal.text = String(displayRaffle.amount)
        }
        
        viewInit()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func viewInit(){
        
        editName.isUserInteractionEnabled = false
        editName.backgroundColor = UIColor.lightGray
        editDescription.isUserInteractionEnabled = false
        editDescription.layer.backgroundColor = UIColor.lightGray.cgColor
        editCoverBtn.isUserInteractionEnabled = false
        editCoverBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        editPrice.isUserInteractionEnabled = false
        editPrice.backgroundColor = UIColor.lightGray
        editTotal.isUserInteractionEnabled = false
        editTotal.backgroundColor = UIColor.lightGray
        
    }
    
    func activateView(){
        
        editName.isUserInteractionEnabled = true
        editName.backgroundColor = UIColor.white
        editDescription.isUserInteractionEnabled = true
        editDescription.layer.backgroundColor = UIColor.white.cgColor
        editCoverBtn.isUserInteractionEnabled = true
        editCoverBtn.setTitleColor(UIColor.link, for: UIControl.State.normal)
        
        if raffle?.sold_amount == 0 {
            
            editPrice.isUserInteractionEnabled = true
            editPrice.backgroundColor = UIColor.white
            editTotal.isUserInteractionEnabled = true
            editTotal.backgroundColor = UIColor.white
            
        }
        
        
    }
    
    @IBAction func editRaffle(_ sender: UIButton) {
        
        activateView()
        
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
