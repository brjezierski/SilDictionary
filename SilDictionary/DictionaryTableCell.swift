//
//  DictionaryTableCell.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/16/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

class DictionaryTableCell : UITableViewCell {
    
    @IBOutlet internal var keyLabel: UILabel!
    
    @IBOutlet internal var translationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
