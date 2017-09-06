//
//  Colors.swift
//  MyCalendar
//
//  Created by Jess Chandler on 9/6/17.
//  Copyright © 2017 Jess Chandler. All rights reserved.
//

import Foundation
import UIKit

// MARK: - This App Functions
func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

var dkgrey = hexStringToUIColor(hex: "#43494E")

var vryltblue = hexStringToUIColor(hex: "#CAE5FF")
var ltblue = hexStringToUIColor(hex: "#AAD6FF")
var ltbrightblue = hexStringToUIColor(hex: "#91CAFF")
var brightblue = hexStringToUIColor(hex: "#89C6FF")
var dkblue = hexStringToUIColor(hex: "#4C7699")

var vryltpink = hexStringToUIColor(hex: "#ffe1f0")
var ltpink = hexStringToUIColor(hex: "#ffc3e1")
var ltbrightpink = hexStringToUIColor(hex: "#ffa5d2")
var brightpink = hexStringToUIColor(hex: "#FF69B4")
var dkpink = hexStringToUIColor(hex: "#b2497d")

var vryltorange = hexStringToUIColor(hex: "#fff2e5")
var ltorange = hexStringToUIColor(hex: "#ffd9b2")
var ltbrightorange = hexStringToUIColor(hex: "#ffc17f")
var brightorange = hexStringToUIColor(hex: "#FF8300")
var dkorange = hexStringToUIColor(hex: "#b35c00")
