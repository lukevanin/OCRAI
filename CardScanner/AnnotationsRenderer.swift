//
//  AnnotationsRenderer.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreGraphics

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
            
            // Add layers
            for fragment in fragments {
                
                var points = [CGPoint]()
                
                if let annotations = fragment.annotations?.allObjects as? [FragmentAnnotation] {
                    for annotation in annotations {
                        if let vertices = annotation.vertices?.array as? [FragmentAnnotationVertex] {
                            let annotationPoints = vertices.map() {
                                $0.point.scale(by: scale)
                            }
                            points.append(contentsOf: annotationPoints)
                        }
                    }
                }
                
                // Draw bounding box
                if let point = points.first {

                    let color = fragment.type.color
                    
                    self.draw(point: point, color: color, context: context.cgContext)
                    
                    var minX = point.x
                    var minY = point.y
                    var maxX = minX
                    var maxY = minY
                    
                    for point in points.dropFirst() {
                        minX = min(minX, point.x)
                        minY = min(minY, point.y)
                        maxX = max(maxX, point.x)
                        maxY = max(maxY, point.y)
                        self.draw(point: point, color: color, context: context.cgContext)
                    }
                    
                    let aabb = CGRect(
                        x: minX,
                        y: minY,
                        width: maxX - minX,
                        height: maxY - minY
                    )
                    
                    let rect = aabb.insetBy(dx: -2, dy: -2)

                    self.draw(rect: rect, color: color, context: context.cgContext)
                }
            }
        }

        return output
    }
    
    private func draw(point: CGPoint, color: UIColor, context: CGContext) {
//        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -2, dy: -2)
//        context.setLineWidth(1.0 / format.scale)
//        context.setStrokeColor(color.withAlphaComponent(0.7).cgColor)
//        context.strokeEllipse(in: rect)
        let rect = CGRect(origin: point, size: .zero).insetBy(dx: -1, dy: -1)
        context.setLineWidth(1.0 / format.scale)
        context.setFillColor(color.withAlphaComponent(0.4).cgColor)
        context.fillEllipse(in: rect)
    }
    
    private func draw(rect: CGRect, color: UIColor, context: CGContext) {
        context.setLineWidth(1.0 / format.scale)
        context.setFillColor(color.withAlphaComponent(0.2).cgColor)
        context.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
        context.fill(rect)
        context.stroke(rect)
    }
}
