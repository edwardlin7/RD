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
    
    var raffles = [Raffle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database:SQLiteDatabase = SQLiteDatabase(databaseName: "RaffleDatabase")
        
        
        database.insertRaffle(raffle: Raffle(
            name:"Olympics 2020",
            description:"This is a cancelled Olympics",
            cover:"This is a cover",
            amount:1000))
        
        database.insertRaffle(raffle: Raffle(
            name:"World Cup 2022",
            description:"This is a normal World Cup",
            cover:"This is another cover",
            amount:500))
        
        database.insertRaffle(raffle: Raffle(
            name:"Kingston Open 2045",
            description:"This is a fake game",
            cover:"This is another cover again",
            amount:433))
        
        
        
        //database.deleteAll()
        
        raffles = database.selectAllRaffles()
        print(raffles)
    }


}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(raffles.count)
        return raffles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "raffleCell", for: indexPath) as? raffleCell
        
        let raffle = raffles[indexPath.row]
        
        cell?.cellDelegate = self
        cell?.index = indexPath
        cell?.raffleName.text = raffle.name
        
        return cell!
    }
}

extension ViewController: TableViewRaffle{
    func onClickCell(index: Int) {
        print(raffles[index].description, "\n",raffles[index].cover, "\n", raffles[index].amount)
    }
}

