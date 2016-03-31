//
//  PrevSubmTableViewCell.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 13/03/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit

class PrevSubmTableViewCell: UITableViewCell {
    @IBOutlet var quizID:UILabel!
    @IBOutlet var quizDescription:UILabel!
    @IBOutlet var noSubmissions:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
