//
//  OptionTableViewCell.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit

class OptionTableViewCell: UITableViewCell {
    @IBOutlet var optionWebView:UIWebView! //View to show view
    @IBOutlet var buttonImage:UIImageView! //View to show selected option
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
