//
//  addRaffleController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/2.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class addRaffleController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

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
        raffleName.layer.borderColor = UIColor.systemGray3.cgColor
        raffleDescription.layer.borderWidth = 1
        raffleDescription.layer.borderColor = UIColor.systemGray3.cgColor
        ticketPrice.layer.borderWidth = 1
        ticketPrice.layer.borderColor = UIColor.systemGray3.cgColor
        raffleAmount.layer.borderWidth = 1
        raffleAmount.layer.borderColor = UIColor.systemGray3.cgColor
        
        let image = UIImage(named: "raffleCover")
        raffleCover.image = image
        
        initializeTextFields()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        raffleName.resignFirstResponder()
        raffleDescription.resignFirstResponder()
        ticketPrice.resignFirstResponder()
        raffleAmount.resignFirstResponder()
        
    }
    
    func initializeTextFields() {
      ticketPrice.delegate = self
      ticketPrice.keyboardType = UIKeyboardType.numberPad
      raffleAmount.delegate = self
      raffleAmount.keyboardType = UIKeyboardType.numberPad
    
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField{
        case ticketPrice:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789")
        case raffleAmount:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789")
        default:
            return true
        }
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
        
        let raffleNameInput = raffleName.text
        let raffleDescriptionInput = raffleDescription.text ?? "N/A"
        let raffleCoverInput = (raffleCover.image?.jpegData(compressionQuality: 0.3)?.base64EncodedString())!
        let raffleAmountInput = raffleAmount.text
        let rafflePriceInput = ticketPrice.text
        let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
        
        if raffleName.text!.isEmpty || raffleAmount.text!.isEmpty || raffleAmount.text!.isEmpty || ticketPrice.text!.isEmpty{
            
            let alert = UIAlertController(title: "Make sure the raffle has a name, ticket price and available amount.", message:nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
        }else if !database.checkRaffleExists(name: raffleNameInput!){
            
            let alert = UIAlertController(title: "Raffle \"\(raffleNameInput!)\" already exists", message:nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            
            database.insertRaffle(raffle: Raffle(
                name:raffleNameInput!,
                margin:margin,
                description:raffleDescriptionInput,
                cover:raffleCoverInput,
                amount:Int32(raffleAmountInput!)!,
                price:Int32(rafflePriceInput!)!,
                sold_amount:0,
                drawn: 0
            ))
            
            let confirmAlert = UIAlertController(title: "A new raffle has been created!", message: nil, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "OK", style: .default){ (action) in
            self.performSegue(withIdentifier: "addRaffleSegue", sender: action)
            }
            
            confirmAlert.addAction(confirmAction)
            present(confirmAlert, animated: true, completion: nil)
        }
    }
        
}
