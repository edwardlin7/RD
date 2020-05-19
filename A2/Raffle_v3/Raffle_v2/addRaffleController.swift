//
//  addRaffleController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/2.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class addRaffleController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var raffleName: UITextField!
    
    @IBOutlet var raffleDescription: UITextView!
    
    @IBOutlet var raffleCover: UIImageView!
    
    @IBOutlet var ticketPrice: UITextField!
    
    @IBOutlet var raffleAmount: UITextField!
    
    var margin:Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()

        // Do any additional setup after loading the view.
    }
    
    func viewInit(){
        
        raffleName.layer.borderWidth = 1
        raffleName.layer.borderColor = UIColor.gray.cgColor
        raffleDescription.layer.borderWidth = 1
        raffleDescription.layer.borderColor = UIColor.gray.cgColor
        ticketPrice.layer.borderWidth = 1
        ticketPrice.layer.borderColor = UIColor.gray.cgColor
        raffleAmount.layer.borderWidth = 1
        raffleAmount.layer.borderColor = UIColor.gray.cgColor
        
        let image = UIImage(named: "raffleCover")
        raffleCover.image = image
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        raffleName.resignFirstResponder()
        raffleDescription.resignFirstResponder()
        ticketPrice.resignFirstResponder()
        raffleAmount.resignFirstResponder()
        
    }
    
    @IBAction func addCoverBtn(_ sender: UIButton) {
        
        
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
        
        raffleCover.image = nil
        raffleCover.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func normalOrMargin(_ sender: UISwitch) {
        // 0 means type is margin, is normal raffle otherwise
        if sender.isOn == true{
            margin = 1
        }else{
            margin = 0
        }
        
    }
    
    @IBAction func confirmAddRaffle(_ sender: UIButton) {
        
        let raffleNameInput = raffleName.text!
        let raffleDescriptionInput = raffleDescription.text!
        let raffleCoverInput = (raffleCover.image?.jpegData(compressionQuality: 0.3)?.base64EncodedString())!
        let raffleAmountInput = raffleAmount.text!
        let rafflePriceInput = ticketPrice.text!
        
        let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
        
        database.insertRaffle(raffle: Raffle(
            name:raffleNameInput,
            margin:margin,
            description:raffleDescriptionInput,
            cover:raffleCoverInput,
            amount:Int32(raffleAmountInput) ?? 0,
            price:Int32(rafflePriceInput) ?? 0,
            sold_amount:0
        ))
        
        let confirmAlert = UIAlertController(title: "A new raffle has been created!", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default){ (action) in
        self.performSegue(withIdentifier: "addRaffleSegue", sender: action)
        }
        
        confirmAlert.addAction(confirmAction)
        present(confirmAlert, animated: true, completion: nil)
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
