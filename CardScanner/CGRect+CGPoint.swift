//
//  CGRect+CGPoint.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension CGRect {
    
    init?(axisAlignedBoundingBoxForPoints points: [CGPoint]) {
        
        guard let point = points.first else {
            return nil
        }
        
        var minX = point.x
        var minY = point.y
        var maxX = minX
        var maxY = minY
        
        for point in points.dropFirst() {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        self.init(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}
