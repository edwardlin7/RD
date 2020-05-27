//
//  editRaffleController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/3.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class editRaffleController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet var editName: UITextField!
    
    @IBOutlet var editDescription: UITextView!
    
    @IBOutlet var editCover: UIImageView!
    
    @IBOutlet var editCoverBtn: UIButton!
    
    @IBOutlet var editPrice: UITextField!
    
    @IBOutlet var soldAmount: UILabel!
    
    @IBOutlet var editTotal: UITextField!
    
    @IBOutlet weak var raffleType: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editSaveBtn: UIButton!
    @IBOutlet weak var editCancelBtn: UIButton!
    @IBOutlet weak var editDeleteBtn: UIButton!
    @IBOutlet weak var editSellBtn: UIButton!
    
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    var raffle:Raffle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayData()
        viewInit()
        
    }
    
    func passDataToTicketAndDraw(){
        
        let ticketView = self.tabBarController!.viewControllers![1] as! TicketViewController
        let drawView = self.tabBarController!.viewControllers![2] as! DrawViewController
        ticketView.ss = raffle!.name
        drawView.raffleID = raffle!.ID
        ticketView.tickets = database.selectTicketsByRaffle(name: raffle!.name)
        //drawView.tickets = database.selectTicketsByRaffle(name: raffle!.name)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        editName.resignFirstResponder()
        editPrice.resignFirstResponder()
        editTotal.resignFirstResponder()
        editDescription.resignFirstResponder()
        
    }
    
    func viewInit(){
        
        editName.layer.borderWidth = 1
        editName.layer.borderColor = UIColor.systemGray3.cgColor
        editDescription.layer.borderWidth = 1
        editDescription.layer.borderColor = UIColor.systemGray3.cgColor
        editPrice.layer.borderWidth = 1
        editPrice.layer.borderColor = UIColor.systemGray3.cgColor
        editTotal.layer.borderWidth = 1
        editTotal.layer.borderColor = UIColor.systemGray3.cgColor
        raffleType.textColor = UIColor.systemGray
        
        editName.isUserInteractionEnabled = false
        editName.backgroundColor = UIColor.systemGray4
        editDescription.isUserInteractionEnabled = false
        editDescription.layer.backgroundColor = UIColor.systemGray4.cgColor
        editCoverBtn.isUserInteractionEnabled = false
        editCoverBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        editPrice.isUserInteractionEnabled = false
        editPrice.backgroundColor = UIColor.systemGray4
        editTotal.isUserInteractionEnabled = false
        editTotal.backgroundColor = UIColor.systemGray4
        editCancelBtn.isHidden = true
        editSaveBtn.isHidden = true
        editBtn.isHidden = false
        editDeleteBtn.isHidden = false
        editSellBtn.isHidden = false
        
    }
    
    func displayData(){
        
        if let displayRaffle = raffle{
            editName.text = displayRaffle.name
            if displayRaffle.margin == 1 {
                raffleType.text = "#margin#"
            }else{
                raffleType.text = "#regular#"
            }
            editDescription.text = displayRaffle.description
            editCover.image = Helper.decodeImage(imageBase64: displayRaffle.cover )
            editPrice.text = String(displayRaffle.price)
            soldAmount.text = String(displayRaffle.sold_amount)
            editTotal.text = String(displayRaffle.amount)
            passDataToTicketAndDraw()
        }
    }
    
    func activateView(){
        
        editDescription.isUserInteractionEnabled = true
        editDescription.layer.backgroundColor = UIColor.white.cgColor
        editCoverBtn.isUserInteractionEnabled = true
        editCoverBtn.setTitleColor(UIColor.link, for: UIControl.State.normal)
        editBtn.isHidden = true
        editDeleteBtn.isHidden = true
        editSellBtn.isHidden = true
        editCancelBtn.isHidden = false
        editSaveBtn.isHidden = false
        
        if raffle?.sold_amount == 0 {
            
            editName.isUserInteractionEnabled = true
            editName.backgroundColor = UIColor.white
            editPrice.isUserInteractionEnabled = true
            editPrice.backgroundColor = UIColor.white
            editTotal.isUserInteractionEnabled = true
            editTotal.backgroundColor = UIColor.white
        }
        
        
    }
    
    @IBAction func editRaffle(_ sender: UIButton) {
        
        activateView()
        
    }
    @IBAction func editCancel(_ sender: UIButton) {
        
        displayData()
        viewInit()
        
    }
    
    @IBAction func coverEdit(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
            
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        self.present(actionSheet, animated: true, completion: nil)
        
    }
        
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
              
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
              
        editCover.image = nil
        editCover.image = image
              
        picker.dismiss(animated: true, completion: nil)
              
    }
          
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
              
        picker.dismiss(animated: true, completion: nil)
              
    }
    

    @IBAction func saveChanges(_ sender: UIButton) {
        
        let raffleNameInput = editName.text!
        let raffleDescriptionInput = editDescription.text!
        let raffleCoverInput = (editCover.image?.jpegData(compressionQuality: 0.3)?.base64EncodedString())!
        let rafflePriceInput = editPrice.text!
        let raffleAmountInput = editTotal.text!
        
        database.updateRaffle(raffle: Raffle(
            ID:raffle!.ID,
            name:raffleNameInput,
            margin:raffle!.margin,
            description:raffleDescriptionInput,
            cover:raffleCoverInput,
            amount:Int32(raffleAmountInput) ?? 0,
            price:Int32(rafflePriceInput) ?? 0,
            sold_amount:Int32(soldAmount.text!)!,
            drawn: 0
        ))
        
        let confirmAlert = UIAlertController(title: "Changes saved!", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default){ (action) in
            self.performSegue(withIdentifier: "EditBackToMainSegue", sender: nil)
            //self.dismiss(animated: false)
        }
        
        confirmAlert.addAction(confirmAction)
        present(confirmAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteRaffle(_ sender: Any) {
        
        let confirmAlert = UIAlertController(title: "Are you sure you want to delete Raffle “\(raffle!.name)”?", message: nil, preferredStyle: .alert)
               
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler:{ (action) in
                    self.database.deleteRaffleBy(ID: self.raffle!.ID, name: self.raffle!.name)
                    self.performSegue(withIdentifier: "EditBackToMainSegue", sender: nil)
               })
               let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
               confirmAlert.addAction(cancelAction)
               confirmAlert.addAction(confirmAction)
               present(confirmAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "SellRaffleSegue" {
            
            guard let sellRaffleController = segue.destination as? SellRaffleController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            sellRaffleController.raffle = self.raffle
            
        }
    }
    
    @IBAction func unwindFromSellRaffleAC(_ sender: UIStoryboardSegue){
        
        if sender.source is SellRaffleController {
            if let senderVC = sender.source as? SellRaffleController{
                raffle = database.selectRaffleByName(name: editName.text!)
            }
            displayData()
        }
    }
    


}
