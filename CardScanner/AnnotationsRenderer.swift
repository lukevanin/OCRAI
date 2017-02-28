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
    
    func render() -> UIImage? {
        
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
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
                let color = fragment.type.color
                
                context.cgContext.setLineWidth(1.0 / format.scale)
                context.cgContext.setFillColor(color.withAlphaComponent(0.2).cgColor)
                context.cgContext.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
                
                if let point = points.first {
                    
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
                    
                    let rect = aabb.insetBy(dx: -2, dy: -2)
                    context.cgContext.fill(rect)
                    context.cgContext.stroke(rect)
                }
            }
        }

        return output
    }
}
