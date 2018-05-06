//
//  Created by Mehdi.
//  Copyright © 2018 Your Company. All rights reserved.
//  

import UIKit
import Alamofire

class API {
    
    var purchases = [Purchase]()
    static let shared = API()
    
    let headers:HTTPHeaders = [
        "X-Username":   Constants.username,
        "X-Api-Key":    Constants.key
    ]
    
    func getRecord(forID recordID:String)
    {
        Alamofire
            .request(Constants.url + "/records/" + recordID
                , method: .get
                , parameters: nil
                , encoding: URLEncoding.default
                , headers: headers)
            .responseJSON { response in
                if  let json        = response.result.value as? [String: Any],
                    let status      = json["status"] as? String,
                    let timestamp   = json["timestamp"] as? Double,
                    let data        = json["data"] as? [String: String],
                    let habitat     = data["habitat"],
                    let owner       = data["owner"]
                {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    
                    let date = formatter.string(from: Date(timeIntervalSince1970: timestamp))
                    
                    let userInfo = [
                        "status": status,
                        "date": date,
                        "habitat": habitat,
                        "owner": owner
                    ]
                    
                    NotificationCenter.default.post(name: .getRecordReceived, object: nil, userInfo: userInfo)
                }
        }
    }
    
    func getLastPurchase(of habitat:String) -> Purchase?
    {
        return purchases.first { $0.habitat == habitat }
        /*
         for purchase in purchases
         {
            if purchase.habitat == habitat {
                return purchase
            }
         }
         return nil
         */
    }
    
    /**
     *
     * RESPONSE STATUS MEANING
     * queued: this means that the record is queued to be added to the blockchain
     * unpublished: this means that the record has been processed, but hasn’t been published to the blockchain yet
     * complete: this means that the record has been added to the blockchain, and has been confirmed by the blockchain mechanism
     *
     */
    func createRecord(habitat: String, owner: String) {
        
        let parameters = [
            "datastoreId": Constants.datastoreID,
            "habitat" : habitat,
            "owner" : owner,
            "firstname" : "\(habitat);\(owner)"
        ];
        
        Alamofire
            .request(Constants.url + "/records"
                , method: .post
                , parameters: parameters
                , encoding: URLEncoding.default
                , headers: headers)
            .responseJSON { response in
                
                if  let json = response.result.value as? [String: Any],
                    let status  = json["status"] as? String
                {
                    let userInfo = [
                        "status": status,
                        "habitat": habitat,
                        "owner": owner
                    ]
                    
                    NotificationCenter.default.post(name: .createRecordReceived
                        , object: nil
                        , userInfo: userInfo)
                }
        }
    }
    
    func getAllRecords()
    {
        // when the request is completed and the JSON data returns, the closure is executed, and provided with a response parameter
        Alamofire
            .request(Constants.url + "/records"
                , method: .get
                , parameters: ["datastoreId": Constants.datastoreID]
                , encoding: URLEncoding.default
                , headers: headers)
            .responseJSON { [unowned self] response in
            
                // decompose the records from the JSON data, and iterate over every element in the records array with for-in
                if  let json = response.result.value as? [String: Any],
                    let records = json["records"] as? [[String: Any]]
                {
                    self.purchases.removeAll()
                    
                    // for every record, we decompose individual data elements such as recordID, label and timestamp, and add those to a Purchase object, which is subsequently added to the purchases instance property
                    for item in records
                    {
                        let purchase = Purchase()
                        
                        if let label = item["label"] as? String
                        {
                            let a = label.split(separator: ";").map { String($0) }
                            
                            if a.count != 2 {
                                continue
                            }
                            
                            purchase.habitat = a[0]
                            purchase.owner = a[1]
                        }
                        
                        if let recordID = item["id"] as? String {
                            purchase.recordID = recordID
                        }
                        
                        if let timestamp = item["timestamp"] as? Double {
                            purchase.date = Date(timeIntervalSince1970: timestamp)
                        }
                        
                        self.purchases += [purchase]
                    }
                    
                    // sort the purchases so they’re organized most recent first
                    self.purchases.sort { $0.date > $1.date }
                    
                    NotificationCenter.default.post(name: .recordsUpdated, object: nil)
                }
        }
    }
}

extension Notification.Name
{
    static let recordsUpdated = Notification.Name("recordsUpdated")
    static let createRecordReceived = Notification.Name("createRecordReceived")
    static let getRecordReceived = Notification.Name("getRecordReceived")
}
