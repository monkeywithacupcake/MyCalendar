//
//  DayTableViewCell.swift
//  MyCalendar
//
//  Created by Jess Chandler on 9/8/17.
//  Copyright © 2017 Jess Chandler. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    // MARK: - Properties

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var stopTimeLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTitlelabel: UILabel!
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = vryltorange
        eventTitlelabel.textColor = dkgrey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //self.backgroundColor = brightorange
    }

}
