//
//  Created by Mehdi.
//  Copyright © 2018 Your Company. All rights reserved.
//  

import Foundation

class Purchase: CustomStringConvertible {
    
    var description: String {
        return "recordID = \(recordID), habitat = \(habitat), owner = \(owner), date = \(date)"
    }
    var habitat: String = ""
    var owner: String = ""
    var recordID: String = ""
    var date: Date = Date()
}
