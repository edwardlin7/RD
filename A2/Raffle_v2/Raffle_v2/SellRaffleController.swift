//
//  SellRaffleController.swift
//  Raffle_v2
//
//  Created by Chengming Liu on 23/5/20.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class SellRaffleController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    //var Names = [ "ricardo farmilo ", "Tony laoshi", "jack millos", "Heena inidan", "Yulong Cai", "Matthew Springer" ]
    //var Nums = [ "123214", "44444", "6746464", "252442", "3252352", "32523523" ]
    var Names = [String]()
    var Nums = [String]()
    var originalNameList:[String] = Array()
    
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    var raffle:Raffle?
    var customers = [Customer]()
    var tickets = [Ticket]()
    var segueOrNot:Int = 0
    
    @IBOutlet weak var searchNameBar: UITextField!
    @IBOutlet weak var customerList: UITableView!
    @IBOutlet weak var sellRaffleName: UITextField!
    @IBOutlet weak var sellRafflePrice: UITextField!
    @IBOutlet weak var sellRaffleCover: UIImageView!
    @IBOutlet weak var sellRaffleNum: UITextField!
    @IBOutlet weak var sellRaffleSubtotal: UITextField!
    @IBOutlet weak var sellCustomerName: UITextField!
    @IBOutlet weak var sellPhoneNum: UITextField!
    @IBOutlet weak var raffleType: UILabel!
    @IBOutlet weak var sellTotal: UILabel!
    @IBOutlet weak var phoneNumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        
        let customers = database.selectAllCus()
        for cus in customers {
            Names.append(cus.name)
            Nums.append(cus.mobile)
        }
        
        for name in Names {
            originalNameList.append(name)
        }
        
        searchNameBar.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        sellRaffleNum.addTarget(self, action: #selector(textFieldDidEndEditing(_ :)), for: UIControl.Event.editingChanged)
    }
    
    //The autocomplete suggestion box's height depends on the number of cells
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        customerList.frame = CGRect(x: customerList.frame.origin.x, y: customerList.frame.origin.y, width: customerList.frame.size.width, height: customerList.contentSize.height)
    }
    
    //The autocomplete suggestion box's height depends on the number of cells
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customerList.frame = CGRect(x: customerList.frame.origin.x, y: customerList.frame.origin.y, width: customerList.frame.size.width, height: customerList.contentSize.height)
    }
    
    func viewInit(){
        sellRaffleName.isUserInteractionEnabled = false
        sellRafflePrice.isUserInteractionEnabled = false
        sellRaffleSubtotal.isUserInteractionEnabled = false
        //sellRaffleNum.text = "0"
        sellRaffleName.backgroundColor = UIColor.systemGray4
        sellRafflePrice.backgroundColor = UIColor.systemGray4
        sellRaffleSubtotal.backgroundColor = UIColor.systemGray4
        sellRaffleSubtotal.text = "0"
        raffleType.textColor = UIColor.systemGray
        customerList.isHidden = true
        customerList.layer.borderWidth = 1.0
        customerList.layer.borderColor = UIColor.systemGray3.cgColor
        initializeTextFields()
        displayData()
        
    }
    func initializeTextFields() {
      sellRaffleNum.delegate = self
      sellRaffleNum.keyboardType = UIKeyboardType.numberPad
      sellPhoneNum.delegate = self
      sellPhoneNum.keyboardType = UIKeyboardType.numberPad
    
    }
    
    func displayData(){
        
        if let displayRaffle = raffle{
            sellRaffleName.text = displayRaffle.name
            sellRafflePrice.text = String(displayRaffle.price)
            sellRaffleCover.image = Helper.decodeImage(imageBase64: displayRaffle.cover)
            if displayRaffle.margin == 1 {
                raffleType.text = "#margin#"
            }else{
                raffleType.text = "#regular#"
            }
            sellTotal.text = String(displayRaffle.amount - displayRaffle.sold_amount)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchNameBar.resignFirstResponder()
        sellPhoneNum.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
          return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField{
        case sellRaffleNum:
            if prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789"){
                return Int(prospectiveText)! <= Int(sellTotal.text!)!
            }else{
                return false
            }
        case sellPhoneNum:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "+0123456789")
        default:
            return true
        }
    }
    
    //Dynamically calculate the subtotal depending on input of sellNum
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField{
        case sellRaffleNum:
            subtotalDidChange()
        default:
            break
            
        }
    }
    
    func subtotalDidChange(){
        
        let sellNum = Int(sellRaffleNum.text!) ?? 0
        let price = Int(sellRafflePrice.text!) ?? 0
        sellRaffleSubtotal.text = String(price * sellNum)
    }
    
    @objc func searchRecords(_ textField: UITextField){
        self.Names.removeAll()
        if textField.text?.count != 0 {
            
            for name in originalNameList {
                if let nameToSearch = textField.text{
                    let range = name.lowercased().range(of: nameToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        customerList.isHidden = false
                        phoneNumLabel.isHidden = true
                        self.Names.append(name)
                    }
                    if self.Names.isEmpty{
                        customerList.isHidden = true
                        phoneNumLabel.isHidden = false
                    }
                }
            }
            
        }else{
            customerList.isHidden = true
            phoneNumLabel.isHidden = false
            for name in originalNameList {
                       Names.append(name)
                   }
        }
        customerList.reloadData()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "customerName")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "customerName")
        }
        cell?.textLabel?.text = Names[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchNameBar.text = Names[indexPath.row]
        sellPhoneNum.text = Nums[indexPath.row]
        customerList.isHidden = true
        phoneNumLabel.isHidden = false
    }
    
    @IBAction func sellBtn(_ sender: Any) {
        let subtotal = Int(sellRaffleSubtotal.text ?? "0")!
        if subtotal == 0 {
            let alert = UIAlertController(title: "No tickets being sold!", message:nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            
            let min = 0
            let max = Int(sellTotal.text!)! - 1
            //let ticketNum = Helper.getTicketNum(exclude: excludedTicketNums(), min: min, max: max, type: Int(raffle!.margin))
            let name = sellRaffleName.text!
            let customer = sellCustomerName.text!
            let phone = sellPhoneNum.text!
            let numOfTickets = sellRaffleNum.text!
            let subtotal = sellRaffleSubtotal.text!
            let text = "Raffle: \(name)\nCustomer: \(customer)\nPhone #: \(phone)\nNum of tickets: \(numOfTickets)\nSubtotal: \(subtotal)"
            
            let ticketNums = Helper.getTicketNum(exclude: excludedTicketNums(), min: min, max: max, type: Int(raffle!.margin), numOfTickets: Int(sellRaffleNum.text!)!)
            
            print("Sold \(ticketNums.count) tickets")
            //print("Ticket numbers are \(ticketNums)")
            
            let alert = UIAlertController(title: "Sell this ticket?",
                                          message: "confirmation",
                                          preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler:{(action) in
                //self.database.insertTicket(ticket: Ticket(name: name, ticket_number: Int32(ticketNum), datetime: Helper.getCurrentTime(), customer_name: customer))
                //self.database.updateSoldAmount(raffleName: name, sold: Int(numOfTickets)!)
                self.updateDatabaseAfterSold(name: name, ticket_nums: ticketNums, datetime: Helper.getCurrentTime(), customer: customer, phone:phone)
                var thisTicket = [Ticket]()
                thisTicket = self.database.selectTicketsByRaffle(name: name)
                print(thisTicket)
                self.performSegue(withIdentifier: "SellBackToEditSegue", sender: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            alert.setValue(Helper.alertTextAlignment(text: text), forKey: "attributedMessage")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func updateDatabaseAfterSold(name:String, ticket_nums:[Int], datetime:String, customer: String, phone:String){
        for num in ticket_nums {
            database.insertTicket(ticket: Ticket(name: name, ticket_number: Int32(num), datetime: Helper.getCurrentTime(), customer_name: customer))
        }
        
        if database.checkCustomerExists(name: customer){
            database.insertCustomer(customer: Customer(name: customer, mobile: phone))
        }
        
        database.updateSoldAmount(raffleName: name, sold: ticket_nums.count)
    }

    func excludedTicketNums() -> [Int] {
        var num = [Int]()
        tickets = database.selectTicketsByRaffle(name: raffle!.name)
        for ticket in tickets {
            num.append(Int(ticket.ticket_number))
        }
        return num
    }
}
