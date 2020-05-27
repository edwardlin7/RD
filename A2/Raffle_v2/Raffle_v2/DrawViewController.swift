//
//  DrawViewController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController, UITextFieldDelegate {
    
    var raffle:Raffle?
    var tickets = [Ticket]()
    var raffleID:Int32?
    var winner = "unknown"
    
    @IBOutlet weak var marginNote: UILabel!
    @IBOutlet weak var team2: UITextField!
    @IBOutlet weak var team1: UITextField!
    
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(ss ?? "nothing at all mannnnnnnnnn")
        // Do any additional setup after loading the view.
        raffle = database.selectRaffleBy(ID: raffleID!)
        tickets = database.selectTicketsByRaffle(name: raffle!.name)
        viewInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        raffle = database.selectRaffleBy(ID: raffleID!)
        tickets = database.selectTicketsByRaffle(name: raffle!.name)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
          return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField{
        
        case team1:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789")
        case team2:
            return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789")
        default:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        team1.resignFirstResponder()
        team2.resignFirstResponder()
        return true
    }
    
    func viewInit(){
        
        if Int(raffle!.margin) == 1{
            marginNote.text = "This is a margin raffle depending on the margin between two teams."
            
        }else{
            marginNote.text = "This is a regular, the draw is random."
            team1.isEnabled = false
            team2.isEnabled = false
            team1.backgroundColor = UIColor.systemGray4
            team2.backgroundColor = UIColor.systemGray4
        }
        initializeTextFields()
    }
    
    func initializeTextFields() {
      team1.delegate = self
      team1.keyboardType = UIKeyboardType.numberPad
      team2.delegate = self
      team2.keyboardType = UIKeyboardType.numberPad
    
    }

    
    @IBAction func drawAction(_ sender: Any) {
        
       if Int(raffle!.margin) == 1{
           if team1.text!.isEmpty || team2.text!.isEmpty{
               
               let alert = UIAlertController(title: "Make sure both team's scores are entered.", message:nil, preferredStyle: .alert)
               let action = UIAlertAction(title: "OK", style: .default)
               alert.addAction(action)
               present(alert, animated: true, completion: nil)
               
           }else{
            let marginNum = abs(Int32(team1.text!)! - Int32(team2.text!)!)
            winner = drawMarginRaffle(ticketNums: getTicketNums(), marginNum: marginNum)
           }
           
       }else{
           winner = drawRegular(ticketNums: getTicketNums())
       }
    }
    
    func getTicketNums() -> [Int32]{
        var ticketNums = [Int32]()
        for ticket in tickets {
            ticketNums.append(ticket.ticket_number)
        }
        return ticketNums
    }
    
    func drawMarginRaffle(ticketNums:[Int32], marginNum:Int32) -> String{
        
        if ticketNums.isEmpty{
            let alert = UIAlertController(title: "Draw Failed", message:"This raffle doesn't have an entrant yet.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return "unknown"
        }else{
            database.drawRaffleBy(ID: raffleID!)
            
            if ticketNums.contains(marginNum){
                let ticket  = database.selectTicketByNumber(ticket_number: marginNum)
                let customers = database.selectCustomersByName(customer_name: ticket.customer_name)
                let phone = customers[0].mobile
                let text = "\nTicket#: \(marginNum)\nName: \(ticket.customer_name)\nPhone#: \(phone)"
                
                let alert = UIAlertController(title: "Winner!", message:nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default){ (action) in
                self.performSegue(withIdentifier: "DrawBackToMain", sender: action)
                }
                alert.addAction(action)
                alert.setValue(Helper.alertTextAlignment(text: text), forKey: "attributedMessage")
                present(alert, animated: true, completion: nil)
                return ticket.customer_name
                
            }else{
                let alert = UIAlertController(title: "No one wins", message:"Ticket #\(marginNum) has never been sold.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                return "No one"
            }
            
        }
        
    }
    
    func drawRegular(ticketNums:[Int32]) -> String{
        
        if ticketNums.isEmpty{
            let alert = UIAlertController(title: "Draw Failed", message:"This raffle doesn't have an entrant yet.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return "unknown"
        }else{
            let winner = Int32.random(in: 0...ticketNums.max()!)
            let ticket  = database.selectTicketByNumber(ticket_number: winner)
            let customers = database.selectCustomersByName(customer_name: ticket.customer_name)
            let phone = customers[0].mobile
            let text = "\nTicket#: \(winner)\nName: \(ticket.customer_name)\nPhone#: \(phone)"
            database.drawRaffleBy(ID: raffleID!)
            
            let alert = UIAlertController(title: "Winner!", message:nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default){ (action) in
            self.performSegue(withIdentifier: "DrawBackToMain", sender: action)
            }
            alert.addAction(action)
            alert.setValue(Helper.alertTextAlignment(text: text), forKey: "attributedMessage")
            present(alert, animated: true, completion: nil)
            return ticket.customer_name
        }
        
        
    }
    
}
