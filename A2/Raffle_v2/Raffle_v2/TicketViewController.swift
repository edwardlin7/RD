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
    
    var tickets = [Ticket]()
    var ss:String?
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(ss ?? "nothing at all mannnnnnnnnn")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        ticketTableView.reloadData()
        //print("view appear!!!!!!!!!!!!!!!!!!!!!")
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
            
            let selectedTicket = tickets[indexPath.row]
            
            ticketDetialView.ticket = selectedTicket
            ticketDetialView.aCustomer = database.selectCustomersByName(customer_name: selectedTicket.customer_name)
            
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = tickets[indexPath.row]
            
        print("config ??")
        return UIContextMenuConfiguration(identifier: "my-menu" as NSCopying, previewProvider: nil) { suggestedActions in

            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                print("Sharing \(item)")
            }

            // Create other actions...

            return UIMenu(title: "", children: [share])
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
        
        let ticket = tickets[indexPath.row]
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
