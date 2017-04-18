//
//  TextAnnotationsRenderer.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/11.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

struct TextAnnotationsRenderer: AnnotationsRenderer {
    
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
        
        return renderer.image { (context) in
            render(size: size, context: context.cgContext)
        }
    }
    
    private func render(size: CGSize, context: CGContext) {

        // Calculate scale from original image space, to render space.
//        let scale = CGPoint(
//            x: size.width / document.imageSize.width,
//            y: size.height / document.imageSize.height
//        )
//        
//        let bounds = CGRect(origin: .zero, size: size)
//        
//        let view = UIView(frame: bounds)
//        //        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        
//        for fragment in document.allFields {
//            
//            guard let text = fragment.value else {
//                continue
//            }
//            
//            let vertices = fragment.allVertices()
//            let points = vertices.map { $0.point.scale(by: scale) }
//            
//            guard let aabb = CGRect(axisAlignedBoundingBoxForPoints: points) else {
//                continue
//            }
//
//            let backgroundColor = fragment.type.accentColor
//            let foregroundColor = UIColor.white
//            
//            let backgroundFrame = aabb.insetBy(dx: -2, dy: -2);
//            let background = UIView(frame: backgroundFrame)
//            background.backgroundColor = backgroundColor
//            background.isOpaque = true
//            view.addSubview(background)
//            
//            let labelFrame = aabb.insetBy(dx: 0, dy: 0)
//            
////            let font = UIFont.boldSystemFont(ofSize: 50)
//            let font = UIFont(name: "Helvetica-Light", size: 50)
//            
//            let label = PaddedLabel(frame: labelFrame)
//            label.text = text
//            label.textColor = foregroundColor
//            label.backgroundColor = backgroundColor
//            label.isOpaque = false
//            label.font = font
//            label.adjustsFontSizeToFitWidth = true
//            label.minimumScaleFactor = 0.01
//            label.baselineAdjustment = .alignCenters
//            label.numberOfLines = 1
//            label.clipsToBounds = false
//            
//            //            let constraintSize = CGSize(
//            //                width: aabb.size.width,
//            //                height: 0
//            //            )
//            //            let finalSize = label.systemLayoutSizeFitting(constraintSize, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
//            //            label.frame = CGRect(
//            //                origin: .zero,
//            //                size: finalSize
//            //            )
//            
//            view.addSubview(label)
//            
//        }
//        
//        view.layoutIfNeeded()
        
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, screenScale)
//        if let context = UIGraphicsGetCurrentContext() {
//            view.layer.render(in: context)
//        }
//        let output = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
//        print("Rendered view: \(output?.size)")
    }
}
