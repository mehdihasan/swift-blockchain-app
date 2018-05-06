//
//  Created by Mehdi.
//  Copyright © 2018 Your Company. All rights reserved.
//  

import UIKit

class HabitatCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var ownerLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commonInit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit() {
        nameLabel?.text = ""
        ownerLabel?.text = ""
        priceLabel?.text = ""
    }
    
    func setProperties(propertyName: String, owner: String?, price: Int) {
        nameLabel?.text = propertyName
        ownerLabel?.text = owner == nil ? "For sale!" : "Currently owned by: \(owner!)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let price = formatter.string(for: price) {
            priceLabel?.text    = "\(price) M"
        }
    }
    
}
