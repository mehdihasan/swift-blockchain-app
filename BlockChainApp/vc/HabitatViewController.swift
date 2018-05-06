//
//  Created by Mehdi.
//  Copyright © 2018 Your Company. All rights reserved.
//  

import UIKit

class HabitatViewController: UITableViewController {

    let habitats = [
        ["Antoniadi", 10000],
        ["Cassini", 25000],
        ["Copernicus", 35000],
        ["de Vaucouleurs", 56000],
        ["Dollfus", 99000],
        ["Greeley", 120000],
        ["Herschel", 250000],
        ["Huygens", 314150],
        ["Koval'sky", 370000],
        ["Newton", 450000],
        ["Schiaparelli", 510000],
        ["Tikhonravov", 997000]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HabitatCell", bundle: nil), forCellReuseIdentifier: "habitatCell")

        // On records updated
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordsUpdated(_:)), name: .recordsUpdated, object: nil)
        
        // On recordos created
        NotificationCenter.default.addObserver(self, selector: #selector(onCreateRecordReceived(_:)), name: .createRecordReceived, object: nil)
        
        API.shared.getAllRecords()
        
        // On single record query
        NotificationCenter.default.addObserver(self, selector: #selector(onGetRecordReceived(_:)), name: .getRecordReceived, object: nil)
        
        // refresh functionality
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlChanged(_:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControl
    }
    
    @objc func onGetRecordReceived(_ notification: Notification)
    {
        if  let status      = notification.userInfo?["status"] as? String,
            let date        = notification.userInfo?["date"] as? String,
            let habitat     = notification.userInfo?["habitat"] as? String,
            let owner       = notification.userInfo?["owner"] as? String
        {
            let title = status == "complete" ? "Ownership verified!" : "Ownership not verified"
            let message = "habitat = \(habitat), owner = \(owner), date = \(date), status = \(status)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc func onRefreshControlChanged(_ refreshControl: UIRefreshControl)
    {
        API.shared.getAllRecords()
    }
    
    @objc func onRecordsUpdated(_ notification: Notification)
    {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    @objc func onCreateRecordReceived(_ notification: Notification)
    {
        API.shared.getAllRecords()
        if  let status      = notification.userInfo?["status"] as? String,
            let habitat     = notification.userInfo?["habitat"] as? String,
            let owner       = notification.userInfo?["owner"] as? String
        {
            let message = "status = \(status), habitat = \(habitat), owner = \(owner)"
            
            let alert = UIAlertController(title: "Purchase created in blockchain!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func purchase(habitat: String)
    {
        let alert = UIAlertController(title: "What is the name of the new owner of \(habitat)?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your name here..."
        })
        alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { action in
            if let owner = alert.textFields?.first?.text {
                API.shared.createRecord(habitat: habitat, owner: owner)
            }
        }))
        self.present(alert, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return habitats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "habitatCell", for: indexPath) as! HabitatCell

        if  let habitat = habitats[indexPath.row][0] as? String,
            let price   = habitats[indexPath.row][1] as? Int
        {
            if let purchase = API.shared.getLastPurchase(of: habitat) {
                cell.setProperties(propertyName: habitat, owner: purchase.owner, price: price)
            } else {
                cell.setProperties(propertyName: habitat, owner: nil, price: price)
            }
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let habitat = habitats[indexPath.row][0] as? String
        {
            let alert = UIAlertController(title: "What do you want to do with \(habitat)?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { [weak self] action in
                self?.purchase(habitat: habitat)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if let purchase = API.shared.getLastPurchase(of: habitat)
            {
                alert.addAction(UIAlertAction(title: "Verify", style: .default, handler: { action in
                    API.shared.getRecord(forID: purchase.recordID)
                }))
            }
            
            self.present(alert, animated: true)
        }
    }

}
