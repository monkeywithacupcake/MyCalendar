//
//  MyButton.swift
//  MyCalendar
//
//  Created by Jess Chandler on 9/6/17.
//  Copyright © 2017 Jess Chandler. All rights reserved.
//

import UIKit

class MyButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()


        let color = ltorange
        let disabledColor = color.withAlphaComponent(0.2) // shade

        // set the sizes
        let buttonWidth = 100
        let buttonHeight = 100

        self.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
        self.frame.origin = CGPoint(
            x: (((superview?.frame.width)! / 2) - (self.frame.width / 2)),
            y: self.frame.origin.y)

        // set up the background
        self.backgroundColor = dkgrey

        // set up the shape and border (same as text color)
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        //self.layer.borderWidth = 3.0
        //self.layer.borderColor = color.cgColor

        // deal with the text - button calls this "Title"
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        //self.titleLabel?.font = UIFont(name: "Arial", size: 24)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
        
        
    }
    


}
