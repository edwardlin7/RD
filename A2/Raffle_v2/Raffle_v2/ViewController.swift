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
        
        //database.deleteAll()
        raffles = database.selectAllRaffles()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @IBAction func returnedFromEdit(segue: UIStoryboardSegue) {
        print ("returned from")
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowEditRaffleSegue" {
            
            guard let editRaffleController = segue.destination as? editRaffleController else{
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let raffleCell = sender as? raffleCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = raffleTableView.indexPath(for: raffleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRaffle = raffles[indexPath.row]
            editRaffleController.raffle = selectedRaffle
            
        }
    }
    
    func decodeImage(imageBase64:String) -> UIImage {
        
        let dataDecoded:NSData = NSData(base64Encoded: imageBase64, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedImage:UIImage = UIImage(data: dataDecoded as Data)!
        
        return decodedImage
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
        print(raffles.count)
        return raffles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "raffleCell", for: indexPath) as? raffleCell
        
        let raffle = raffles[indexPath.row]
        
        let image = decodeImage(imageBase64: raffle.cover)
        
        //let menuInteraction = UIContextMenuInteraction(delegate: self)
        
        //cell?.addInteraction(menuInteraction)
        cell?.cellDelegate = self
        cell?.index = indexPath
        cell?.raffleName.text = raffle.name
        
        if raffle.margin == 1 {
            cell?.raffleType.text = "#margin#"
        }else{
            cell?.raffleType.text = "#regular#"
        }
        
        cell?.raffleCover.image = image
        
        return cell!
    }
    
}

extension ViewController: TableViewRaffle{
    func onClickCell(index: Int) {
        print(raffles[index].description, "\n",raffles[index].cover, "\n", raffles[index].amount)
    }
}

