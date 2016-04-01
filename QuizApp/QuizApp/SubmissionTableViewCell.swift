//
//  SubmissionTableViewCell.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 13/03/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit

class SubmissionTableViewCell: UITableViewCell {
    @IBOutlet var marks:UILabel!
    @IBOutlet var timestamp:UILabel!
    @IBOutlet var number:UILabel!
    @IBOutlet var details:UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
