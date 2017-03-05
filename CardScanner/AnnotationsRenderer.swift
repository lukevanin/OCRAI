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
    let scale: CGFloat
    let fragments: [Fragment]
    let format: UIGraphicsImageRendererFormat
    let renderer: UIGraphicsImageRenderer

    init(size: CGSize, scale: CGFloat, fragments: [Fragment]) {
        self.size = size
        self.scale = scale
        self.fragments = fragments
        
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        self.format = format
        self.renderer = renderer
    }

    func render() -> UIImage? {
        
        let output = renderer.image { (context) in

            // Background
            context.cgContext.saveGState()
            let bounds = CGRect(origin: .zero, size: size)
            
            for fragment in fragments {
                
                let points = fragment.points().map { $0.scale(by: scale) }
                
                if let aabb = self.axisAlignedBoundingBox(forPoints: points) {
                    let rect = aabb.insetBy(dx: -2, dy: -2)

                    context.cgContext.beginPath()
                    context.cgContext.addRect(rect)
                    context.cgContext.addRect(.infinite)
                    context.cgContext.clip(using: .evenOdd)
                }
            }

            let color = UIColor.white.withAlphaComponent(0.1)
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fill(bounds)

            context.cgContext.restoreGState()

            // Draw shapes
            for fragment in fragments {
                
                let points = fragment.points().map { $0.scale(by: scale) }
                
                // Draw bounding box
                let color = fragment.type.color
                
//                for point in points {
//                    self.draw(point: point, color: color, context: context.cgContext)
//                }
                
                if let aabb = self.axisAlignedBoundingBox(forPoints: points) {
                    let rect = aabb.insetBy(dx: -2, dy: -2)
                    self.draw(rect: rect, color: color, context: context.cgContext)
                }
            }
        }

        return output
    }
    
    private func axisAlignedBoundingBox(forPoints points: [CGPoint]) -> CGRect? {
        
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
        
        let aabb = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )

        return aabb
    }
    
    private func draw(point: CGPoint, color: UIColor, context: CGContext) {
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -1, dy: -1)
        context.setLineWidth(1.0 / format.scale)
        context.setFillColor(color.withAlphaComponent(0.4).cgColor)
        context.fillEllipse(in: rect)
    }
    
    private func draw(rect: CGRect, color: UIColor, context: CGContext) {
        
        let lineWidth = 1.0 / format.scale
        
        context.setLineWidth(lineWidth)
        
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        context.stroke(rect.insetBy(dx: -1, dy: -1))
        
        context.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
        context.stroke(rect)

        context.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
        context.stroke(rect)

        context.setFillColor(color.withAlphaComponent(0.1).cgColor)
        context.fill(rect)
    }
}
