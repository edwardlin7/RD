//
//  ViewController.swift
//  Raffle_v2
//
//  Created by cliu18 on 2020/5/1.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var raffleTableView: UITableView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    var winner = "unknown yet"
    var dataSource = "undrawn"
    var allRaffles = [Raffle]()
    var raffles = [Raffle]()
    var customers = [Customer]()
    
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //database.deleteAll()
        initData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("ahahahahahahahahahhahahhaahahha")
        customers = database.selectAllCus()
    }
    
    func initData(){
        allRaffles = database.selectAllRaffles()
        
        for raffle in allRaffles where raffle.drawn == 0{
            print(raffle.drawn)
            raffles.append(raffle)
        }
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            dataSource = "undrawn"
            raffles.removeAll()
            for raffle in allRaffles where raffle.drawn == 0{
                raffles.append(raffle)
            }
            raffleTableView.rowHeight = 130.0
            raffleTableView.reloadData()
            
        }else if sender.selectedSegmentIndex == 1{
            dataSource = "drawn"
            raffles.removeAll()
            for raffle in allRaffles where raffle.drawn == 1{
                raffles.append(raffle)
            }
            raffleTableView.rowHeight = 130.0
            raffleTableView.reloadData()
        }else if sender.selectedSegmentIndex == 2{
            dataSource = "customers"
            raffleTableView.rowHeight = 50.0
            raffleTableView.reloadData()
        }
    }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowEditRaffleSegue" {
            
            guard let tabBarController = segue.destination as? TabBarController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let editView = tabBarController.viewControllers?[0] as? editRaffleController
            
            guard let raffleCell = sender as? raffleCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = raffleTableView.indexPath(for: raffleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRaffle = raffles[indexPath.row]
            
            editView!.raffle = selectedRaffle
            
        }
    }
    
    @IBAction func unwindFromEditVC(_ sender: UIStoryboardSegue){
        
        if sender.source is editRaffleController {
            if let senderVC = sender.source as? editRaffleController{
                raffles.removeAll()
                allRaffles.removeAll()
                initData()
                self.segment.selectedSegmentIndex = 0
            }
            raffleTableView.reloadData()
        }
    }
    
    @IBAction func unwindFromAddVC(_ sender: UIStoryboardSegue){
        if sender.source is addRaffleController{
            if let senderVC = sender.source as? addRaffleController{
                raffles.removeAll()
                allRaffles.removeAll()
                initData()
                self.segment.selectedSegmentIndex = 0
            }
            raffleTableView.reloadData()
        }
    }
    @IBAction func unwindFromDrawVC(_ sender: UIStoryboardSegue){
        if sender.source is DrawViewController{
            if let senderVC = sender.source as? DrawViewController{
                raffles.removeAll()
                allRaffles.removeAll()
                initData()
                self.segment.selectedSegmentIndex = 0
            }
            raffleTableView.reloadData()
        }
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
                                    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = raffles[indexPath.row]
            
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
        //print(raffles.count)
        if dataSource == "customers"{
            return customers.count
        }else{
            return raffles.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "raffleCell", for: indexPath) as? raffleCell
        
        
        
        

        
        
        switch dataSource {
        case "drawn":
            let raffle = raffles[indexPath.row]
            cell?.raffleCover.isHidden = false
            cell?.winner.isHidden = false
            cell?.winnerLabel.isHidden = false
            cell?.customerName.isHidden = true
            cell?.raffleName.isHidden = false
            let image = Helper.decodeImage(imageBase64: raffle.cover)
            //cell?.cellDelegate = self
            cell?.index = indexPath
            cell?.raffleName.text = raffle.name
            
            if raffle.margin == 1 {
                cell?.raffleType.text = "#margin#"
            }else{
                cell?.raffleType.text = "#regular#"
            }
            cell?.winner.text = winner
            cell?.raffleCover.image = image
            cell?.raffleType.textColor = UIColor.systemGray
            print("the source is drawn")
        case "undrawn":
            let raffle = raffles[indexPath.row]
            cell?.raffleName.isHidden = false
            cell?.raffleCover.isHidden = false
            cell?.winner.isHidden = true
            cell?.winnerLabel.isHidden = true
            cell?.customerName.isHidden = true
            let image = Helper.decodeImage(imageBase64: raffle.cover)
            //cell?.cellDelegate = self
            cell?.index = indexPath
            cell?.raffleName.text = raffle.name
            
            if raffle.margin == 1 {
                cell?.raffleType.text = "#margin#"
            }else{
                cell?.raffleType.text = "#regular#"
            }
            cell?.winner.text = winner
            cell?.raffleCover.image = image
            cell?.raffleType.textColor = UIColor.systemGray
            print("the source is undrawn")
        case "customers":
            let customer = customers[indexPath.row]
            cell?.customerName.isHidden = false
            cell?.raffleName.isHidden = true
            cell?.customerName.text = customer.name
            cell?.raffleCover.isHidden = true
            print("the source is customers")
        default:
            break
        }
        
        
        return cell!
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowEditRaffleSegue" && dataSource == "drawn" {
            return false
        }else{
            return true
        }
    }
}


extension ViewController: TableViewRaffle{
    func onClickCell(index: Int) {
        print(raffles[index].description, "\n",raffles[index].cover, "\n", raffles[index].amount)
    }
}

