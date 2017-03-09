//
//  AnnotationsRenderer.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreGraphics

extension Fragment {
    func points() -> [CGPoint] {
        var points = [CGPoint]()
        
        if let annotations = annotations?.allObjects as? [FragmentAnnotation] {
            for annotation in annotations {
                if let vertices = annotation.vertices?.array as? [FragmentAnnotationVertex] {
                    let annotationPoints = vertices.map() {
                        $0.point
                    }
                    points.append(contentsOf: annotationPoints)
                }
            }
        }

        return points
    }
}

struct AnnotationsRenderer {
    
    let size: CGSize
    let document: Document
    let format: UIGraphicsImageRendererFormat
    let renderer: UIGraphicsImageRenderer

    init(size: CGSize, document: Document) {
        self.size = size
        self.document = document

        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )
        
        self.format = format
        self.renderer = renderer
    }

    func render() -> UIImage? {
        
        // Calculate scale from original image space, to render space.
        let screenScale = UIScreen.main.scale
        let scale = CGPoint(
            x: size.width / document.imageSize.width,
            y: size.height / document.imageSize.height
        )
        
        let bounds = CGRect(origin: .zero, size: size)
        
        let view = UIView(frame: bounds)
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        for fragment in document.allFragments {

            guard let text = fragment.value else {
                continue
            }
            
            let vertices = fragment.allVertices()
            let points = vertices.map { $0.point.scale(by: scale) }

            guard let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) else {
                continue
            }
            
            let backgroundFrame = aabb.insetBy(dx: -2, dy: -2);
            let background = UIView(frame: backgroundFrame)
            background.backgroundColor = fragment.type.accentColor
            background.isOpaque = true
            view.addSubview(background)
            
            let labelFrame = aabb.insetBy(dx: 0, dy: 0)

            let label = UILabel(frame: labelFrame)
            label.text = text
            label.textColor = .white
            label.backgroundColor = .clear
            label.isOpaque = false
            label.font = UIFont.boldSystemFont(ofSize: 50)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.01
            label.baselineAdjustment = .alignBaselines
            label.numberOfLines = 0
            label.clipsToBounds = false
            
//            let constraintSize = CGSize(
//                width: aabb.size.width,
//                height: 0
//            )
//            let finalSize = label.systemLayoutSizeFitting(constraintSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
//            label.frame = CGRect(
//                origin: .zero,
//                size: finalSize
//            )

            view.addSubview(label)
            
        }
        
        view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, screenScale)
        //let result = view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
        }
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("Rendered view: \(output?.size)")
        
//        let output = renderer.image { (context) in
//            

//            // Background
//            context.cgContext.saveGState()
//            let bounds = CGRect(origin: .zero, size: size)
//            
//            let fragments = document.allFragments
//            
//            for fragment in fragments {
//                
//                let points = fragment.points().map { $0.scale(by: scale) }
//                
//                if let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) {
//                    let rect = aabb.insetBy(dx: -2, dy: -2)
//
//                    context.cgContext.beginPath()
//                    context.cgContext.addRect(rect)
//                    context.cgContext.addRect(.infinite)
//                    context.cgContext.clip(using: .evenOdd)
//                }
//            }
//
//            let color = UIColor.white.withAlphaComponent(0.1)
////            let color = UIColor.magenta
//            context.cgContext0.setFillColor(color.cgColor)
//            context.cgContext.fill(bounds)
//
//            context.cgContext.restoreGState()
//
//            // Draw shapes
//            for fragment in fragments {
//                
//                let points = fragment.points().map { $0.scale(by: scale) }
//                
//                // Draw bounding box
//                let color = fragment.type.accentColor
////                let color = UIColor.cyan
//                
////                for point in points {
////                    self.draw(point: point, color: color, context: context.cgContext)
////                }
//                
//                if let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) {
//                    let rect = aabb.insetBy(dx: -2, dy: -2)
//                    self.draw(rect: rect, color: color, context: context.cgContext)
//                }
//            }
//        }
//
        return output
    }
    
    private func draw(point: CGPoint, color: UIColor, context: CGContext) {
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -1, dy: -1)
        context.setLineWidth(1.0 / format.scale)
        context.setFillColor(color.withAlphaComponent(0.4).cgColor)
        context.fillEllipse(in: rect)
    }
    
    private func draw(rect: CGRect, color: UIColor, context: CGContext) {
        
        let lineWidth = 1.0 / format.scale
        
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
