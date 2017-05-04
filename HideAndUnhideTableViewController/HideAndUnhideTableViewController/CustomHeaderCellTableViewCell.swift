//
//  CustomHeaderCellTableViewCell.swift
//  HideAndUnhideTableViewController
//
//  Created by ShrawanKumar Sharma on 03/05/17.
//  Copyright © 2017 TableViewCustom. All rights reserved.
//

import UIKit

class CustomHeaderCellTableViewCell: UITableViewCell {

    @IBOutlet var headerTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
