//
//  TicketDetailController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketDetailController: UIViewController, UITextFieldDelegate {

    var ticket:Ticket?
    var aCustomer = [Customer]()
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    
    @IBOutlet weak var ticketNum: UITextField!
    @IBOutlet weak var raffleName: UITextField!
    @IBOutlet weak var customer: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var timeSold: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewInit()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        customer.resignFirstResponder()
        phoneNum.resignFirstResponder()
        
    }
    
    func viewInit(){
        
        ticketNum.isUserInteractionEnabled = false
        ticketNum.backgroundColor = UIColor.systemGray4
        raffleName.isUserInteractionEnabled = false
        raffleName.backgroundColor = UIColor.systemGray4
        timeSold.isUserInteractionEnabled = false
        timeSold.backgroundColor = UIColor.systemGray4
        customer.isUserInteractionEnabled = false
        customer.backgroundColor = UIColor.systemGray4
        phoneNum.isUserInteractionEnabled = false
        phoneNum.backgroundColor = UIColor.systemGray4
        cancelBtn.isHidden = true
        saveBtn.isHidden = true
        editBtn.isHidden = false
        shareBtn.isHidden = false
        displayData()
        initializeTextFields()
        
    }
    
    func initializeTextFields() {
      phoneNum.delegate = self
      phoneNum.keyboardType = UIKeyboardType.numberPad
    }
    
    func displayData(){
        
        if let displayTicket = ticket{
            ticketNum.text = String(displayTicket.ticket_number)
            raffleName.text = displayTicket.name
            customer.text = displayTicket.customer_name
            timeSold.text = displayTicket.datetime
        }
        phoneNum.text = aCustomer[0].mobile
    }
    
    func activateView(){
        
        customer.isUserInteractionEnabled = true
        customer.backgroundColor = UIColor.white
        phoneNum.isUserInteractionEnabled = true
        phoneNum.backgroundColor = UIColor.white
        editBtn.isHidden = true
        saveBtn.isHidden = false
        cancelBtn.isHidden = false
        shareBtn.isHidden = true
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
          return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField{
        case phoneNum:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "+0123456789")
        default:
            return true
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        activateView()
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        viewInit()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        let raffle = database.selectRaffleByName(name: ticket!.name)
        let tPrice = String(raffle.price)
        let tNum = String(ticket!.ticket_number)
        let tName = "Name: \(ticket!.customer_name)"
        let tTime = "Purchased \(ticket!.datetime)"
        let text = "\(tName), Ticket#\(tNum), $\(tPrice), \(tTime)"
        
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction func saveEdit(_ sender: Any) {
        
        if customer.text!.isEmpty || phoneNum.text!.isEmpty{
            let alert = UIAlertController(title: "Make sure a customer name and phone number are entered.", message: nil, preferredStyle: .alert)
                   
                   let confirmAction = UIAlertAction(title: "OK", style: .default)
                   
                   alert.addAction(confirmAction)
                   present(alert, animated: true, completion: nil)
        }else{
            if database.checkCustomerExists(name: customer.text!){
                database.insertCustomer(customer: Customer(name: customer.text!, mobile: phoneNum.text!))
            }else{
                database.updateCustomer(customer: Customer(ID: aCustomer[0].ID, name: customer.text!, mobile: phoneNum.text!))
            }
            
            database.updateTicketCustomer(ID: ticket!.ID, customerName: customer.text!)
            
            let confirmAlert = UIAlertController(title: "Changes saved!", message: nil, preferredStyle: .alert)
                           
            let confirmAction = UIAlertAction(title: "OK", style: .default){ (action) in
                            self.performSegue(withIdentifier: "TicketDetialBackToTicketListSegue", sender: nil)
                        }
                           
            confirmAlert.addAction(confirmAction)
            present(confirmAlert, animated: true, completion: nil)
        }
        
    }
    

}
