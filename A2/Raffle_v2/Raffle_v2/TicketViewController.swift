//
//  TicketViewController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/26.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var ticketTableView: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    
    var tickets = [Ticket]()
    var allTickets = [Ticket]()
    var ss:String?
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(ss ?? "nothing at all mannnnnnnnnn")
        // Do any additional setup after loading the view.
        for ticket in tickets {
            allTickets.append(ticket)
        }
        searchBar.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
    }
    
    @objc func searchRecords(_ textField: UITextField){
        self.tickets.removeAll()
        if textField.text?.count != 0 {
            
            for ticket in allTickets {
                if let ticketToSearch = textField.text{
                    let range = ticket.customer_name.lowercased().range(of: ticketToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        self.tickets.append(ticket)
                    }
                }
            }
            
        }else{
            for ticket in allTickets {
                       tickets.append(ticket)
                   }
        }
        ticketTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        ticketTableView.reloadData()
        self.parent?.title = "Tickets"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowTicketDetailSegue" {
            
            guard let ticketDetialView = segue.destination as? TicketDetailController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let ticketCell = sender as? TicketViewCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = ticketTableView.indexPath(for: ticketCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTicket = tickets.sorted {$0.ticket_number < $1.ticket_number}[indexPath.row]
            
            ticketDetialView.ticket = selectedTicket
            ticketDetialView.aCustomer = database.selectCustomersByName(customer_name: selectedTicket.customer_name)
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketViewCell", for: indexPath) as? TicketViewCell
        
        let ticket = tickets.sorted {$0.ticket_number < $1.ticket_number}[indexPath.row]
        cell?.ticketNum.text = String(ticket.ticket_number)
        cell?.customer.text = ticket.customer_name
        return cell!
    }
    
    @IBAction func unwindFromTicketDetialVC(_ sender: UIStoryboardSegue){
        
        if sender.source is TicketDetailController {
            if let senderVC = sender.source as? TicketDetailController{
                tickets = database.selectTicketsByRaffle(name: ss!)
            }
            ticketTableView.reloadData()
        }
    }

}
