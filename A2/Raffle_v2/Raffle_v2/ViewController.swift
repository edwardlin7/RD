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
    var dataSource = "undrawn" // Segment buttons value
    var allRaffles = [Raffle]()
    var allRafflesForSearch = [Raffle]()
    var raffles = [Raffle]()
    var customers = [Customer]()
    var allCustomerForSearch = [Customer]()
    
    @IBOutlet weak var searchBar: UITextField!
    
    let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        initData()
        searchBar.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
    }
    
    // objc function for the search bar
    @objc func searchRecords(_ textField: UITextField){
        self.raffles.removeAll()
        self.customers.removeAll()
        if dataSource == "undrawn"{
            if textField.text?.count != 0 {
                for raffle in allRafflesForSearch where raffle.drawn == 0 {
                    if let raffleToSearch = textField.text{
                        let range = raffle.name.lowercased().range(of: raffleToSearch, options: .caseInsensitive, range: nil, locale: nil)
                        if range != nil {
                            self.raffles.append(raffle)
                        }
                    }
                }
            }else{
                for raffle in allRafflesForSearch where raffle.drawn == 0 {
                           raffles.append(raffle)
                       }
            }
        }else if dataSource == "drawn" {
            if textField.text?.count != 0 {
                for raffle in allRafflesForSearch where raffle.drawn == 1 {
                    if let raffleToSearch = textField.text{
                        let range = raffle.name.lowercased().range(of: raffleToSearch, options: .caseInsensitive, range: nil, locale: nil)
                        if range != nil {
                            self.raffles.append(raffle)
                        }
                    }
                }
            }else{
                for raffle in allRafflesForSearch where raffle.drawn == 1 {
                           raffles.append(raffle)
                       }
            }
        }else {
            if textField.text?.count != 0 {
                for customer in allCustomerForSearch {
                    if let customerToSearch = textField.text{
                        let range = customer.name.lowercased().range(of: customerToSearch, options: .caseInsensitive, range: nil, locale: nil)
                        if range != nil {
                            self.customers.append(customer)
                        }
                    }
                }
            }else{
                for customer in allCustomerForSearch {
                           customers.append(customer)
                       }
            }
        }
        raffleTableView.reloadData()
    }
    
    func addNavBarImage() {
        
        let navController = navigationController!
        
        let image = UIImage(named: "icon3.2")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image!.size.width / 2
        let bannerY = bannerHeight / 2 - image!.size.height / 2 
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        raffles.removeAll()
        allRaffles.removeAll()
        customers.removeAll()
        allCustomerForSearch.removeAll()
        initData()
        raffleTableView.reloadData()
        searchBar.text = ""
    }
    
    func initData(){
        allRaffles = database.selectAllRaffles()
        customers = database.selectAllCus()
        
        allRafflesForSearch = allRaffles
        
        allCustomerForSearch = customers
        if dataSource == "undrawn"{
            for raffle in allRaffles where raffle.drawn == 0{
                raffles.append(raffle)
            }
        }else if dataSource == "drawn" {
            for raffle in allRaffles where raffle.drawn == 1{
                raffles.append(raffle)
            }
        }
        
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl){
        searchBar.text = ""
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
            customers.removeAll()
            for customer in allCustomerForSearch{
                customers.append(customer)
            }
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
            
            let selectedRaffle = raffles.sorted {$0.name < $1.name}[indexPath.row]
            
            editView!.raffle = selectedRaffle
            
        }
    }
    
    @IBAction func unwindFromEditVC(_ sender: UIStoryboardSegue){
        
        if sender.source is editRaffleController {
            if let senderVC = sender.source as? editRaffleController{
                self.segment.selectedSegmentIndex = 0
                didChangeSegment(segment)
            }
            raffleTableView.reloadData()
        }
    }
    
    @IBAction func unwindFromAddVC(_ sender: UIStoryboardSegue){
        if sender.source is addRaffleController{
            if let senderVC = sender.source as? addRaffleController{
                self.segment.selectedSegmentIndex = 0
                didChangeSegment(segment)
            }
            raffleTableView.reloadData()
        }
    }
    @IBAction func unwindFromDrawVC(_ sender: UIStoryboardSegue){
        if sender.source is DrawViewController{
            if let senderVC = sender.source as? DrawViewController{
                self.segment.selectedSegmentIndex = 0
                didChangeSegment(segment)
            }
            raffleTableView.reloadData()
        }
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    /*
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = raffles[indexPath.row]

        return UIContextMenuConfiguration(identifier: "my-menu" as NSCopying, previewProvider: nil) { suggestedActions in

            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                print("Sharing \(item)")
            }

            // Create other actions...

            return UIMenu(title: "", children: [share])
        }
    }*/
    
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
        
        //a btn used for debugging
        cell?.buyBtn.isHidden = true
        switch dataSource {
        case "drawn":
            let raffle = raffles.sorted {$0.name < $1.name}[indexPath.row]
            cell?.raffleCover.isHidden = false
            cell?.winner.isHidden = false
            cell?.winner.text = raffle.winner
            cell?.winnerLabel.isHidden = false
            cell?.customerName.isHidden = true
            cell?.raffleName.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            let image = Helper.decodeImage(imageBase64: raffle.cover)
            cell?.cellDelegate = self
            cell?.index = indexPath
            cell?.raffleName.text = raffle.name
            
            if raffle.margin == 1 {
                cell?.raffleType.text = "#margin#"
            }else{
                cell?.raffleType.text = "#regular#"
            }
            cell?.raffleCover.image = image
            cell?.raffleType.textColor = UIColor.systemGray
        case "undrawn":
            let raffle = raffles.sorted {$0.name < $1.name}[indexPath.row]
            //cell?.raffleName.isHidden = false
            cell?.raffleName.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            cell?.raffleCover.isHidden = false
            cell?.winner.isHidden = true
            cell?.winnerLabel.isHidden = true
            cell?.customerName.isHidden = true
            let image = Helper.decodeImage(imageBase64: raffle.cover)
            cell?.cellDelegate = self
            cell?.index = indexPath
            cell?.raffleName.text = raffle.name
            
            if raffle.margin == 1 {
                cell?.raffleType.text = "#margin#"
            }else{
                cell?.raffleType.text = "#regular#"
            }
            cell?.raffleCover.image = image
            cell?.raffleType.textColor = UIColor.systemGray
        case "customers":
            let customer = customers.sorted {$0.name < $1.name}[indexPath.row]
            cell?.customerName.isHidden = false
            //cell?.raffleName.isHidden = false
            cell?.raffleName.text = "Phone#: \(customer.mobile)"
            cell?.raffleName.font = UIFont(name: "HelveticaNeue", size: 16)
            cell?.customerName.text = customer.name
            cell?.raffleCover.isHidden = true
        default:
            break
        }
        return cell!
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowEditRaffleSegue" && (dataSource == "drawn" || dataSource == "customers") {
            return false
        }else{
            return true
        }
    }
}


extension ViewController: TableViewRaffle{
    func onClickCell(index: Int) {
        print(raffles[index].description, "\n",raffles[index].sold_amount, "\n", raffles[index].amount)
    }
}

