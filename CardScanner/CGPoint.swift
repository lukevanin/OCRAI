//
//  CGPoint.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension CGPoint {
    func scale(by scale: CGFloat) -> CGPoint {
        return CGPoint(x: x * scale, y: y * scale)
    }

    func scale(by scale: CGPoint) -> CGPoint {
        return CGPoint(x: x * scale.x, y: y * scale.y)
    }
}
