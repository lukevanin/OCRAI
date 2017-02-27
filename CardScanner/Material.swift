//
//  Material.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/24.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int) {
        let r = (hex >> 0x10) & 0xFF
        let g = (hex >> 0x08) & 0xFF
        let b = (hex >> 0x00) & 0xFF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
}

struct Material {
    struct Color {
        static let red = UIColor(hex: 0xF44336)
        static let pink = UIColor(hex: 0xE91E63)
        static let purple = UIColor(hex: 0x9C27B0)
        static let deepPurple = UIColor(hex: 0x673AB7)
        static let indigo = UIColor(hex: 0x3F51B5)
        static let blue = UIColor(hex: 0x2196F3)
        static let lightBlue = UIColor(hex: 0x03A9F4)
        static let cyan = UIColor(hex: 0x00BCD4)
        static let teal = UIColor(hex: 0x009688)
        static let green = UIColor(hex: 0x4CAF50)
        static let lightGreen = UIColor(hex: 0x8BC34A)
        static let lime = UIColor(hex: 0xCDDC39)
        static let yellow = UIColor(hex: 0xFFEB3B)
        static let amber = UIColor(hex: 0xFFC107)
        static let orange = UIColor(hex: 0xFF9800)
        static let deepOrange = UIColor(hex: 0xFF5722)
        static let brown = UIColor(hex: 0x795548)
        static let grey = UIColor(hex: 0x9E9E9E)
        static let blueGrey = UIColor(hex: 0x607D8B)
        static let black = UIColor.black
        static let white = UIColor.white
    }
}
