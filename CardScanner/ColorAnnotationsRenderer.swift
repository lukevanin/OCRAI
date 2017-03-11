//
//  ColorAnnotationsRenderer.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/11.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

struct ColorAnnotationsRenderer: AnnotationsRenderer {
    
    let document: Document
    let format: UIGraphicsImageRendererFormat
    
    init(document: Document) {
        self.document = document
        self.format = UIGraphicsImageRendererFormat()
    }
    
    func render(size: CGSize) -> UIImage? {
        
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )
        
        return renderer.image() { context in
            render(size: size, context: context.cgContext)
        }
    }
    
    private func render(size: CGSize, context: CGContext) {

        let scale = CGPoint(
            x: size.width / document.imageSize.width,
            y: size.height / document.imageSize.height
        )

        // Background
//        context.saveGState()
//        let bounds = CGRect(origin: .zero, size: size)

//        let fragments = document.allFragments
//
//        for fragment in fragments {
//
//            let points = fragment.points().map { $0.scale(by: scale) }
//
//            if let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) {
//                let rect = aabb.insetBy(dx: -2, dy: -2)
//
//                context.beginPath()
//                context.addRect(rect)
//                context.addRect(.infinite)
//                context.cgContext.clip(using: .evenOdd)
//            }
//        }
//
//        let color = UIColor.white.withAlphaComponent(0.1)
//    //            let color = UIColor.magenta
//        context.cgContext0.setFillColor(color.cgColor)
//        context.cgContext.fill(bounds)
//
//        context.cgContext.restoreGState()

        // Draw shapes
        let fragments = document.allFragments
        for fragment in fragments {

            let points = fragment.points().map { $0.scale(by: scale) }

            // Draw bounding box
            let color = fragment.type.accentColor

    //                for point in points {
    //                    self.draw(point: point, color: color, context: context.cgContext)
    //                }

            if let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) {
                let rect = aabb.insetBy(dx: -2, dy: -2)
                self.draw(rect: rect, color: color, context: context)
            }
        }
    }
    
    private func draw(point: CGPoint, color: UIColor, context: CGContext) {
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -1, dy: -1)
        context.setLineWidth(1.0 / format.scale)
        context.setFillColor(color.withAlphaComponent(0.4).cgColor)
        context.fillEllipse(in: rect)
    }
    
    private func draw(rect: CGRect, color: UIColor, context: CGContext) {
        
//        let lineWidth = 1.0 / format.scale
        
        //        context.setLineWidth(lineWidth)
        //        
        //        context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        //        context.stroke(rect.insetBy(dx: -1, dy: -1))
        //        
        //        context.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
        //        context.stroke(rect)
        //
        //        context.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
        //        context.stroke(rect)
        
        context.setFillColor(color.withAlphaComponent(0.5).cgColor)
        context.fill(rect)
        
        //        context.setFillColor(color.cgColor)
        //        context.fill(rect)
    }
}
