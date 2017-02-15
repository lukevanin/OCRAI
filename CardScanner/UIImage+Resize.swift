//
//  UIImage+Resize.swift
//  AutoTranslate
//
//  Created by Luke Van In on 2017/02/03.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(size: CGSize) -> UIImage {
        let scale = calculateImageScale(size: size)
        return resizeImage(size: size, scale: scale)
    }
    
    private func calculateImageScale(size targetSize: CGSize) -> CGFloat {
        let imageSize = self.size
        let imageAspect = imageSize.width / imageSize.height
        let targetAspect = targetSize.width / targetSize.height
        
        let scale: CGFloat
        
        if imageAspect > targetAspect {
            // Image is wider aspect than target.
            // Scale image by width.
            scale = targetSize.width / imageSize.width
        }
        else {
            // Image is narrower aspect than target.
            // Scale image by height
            scale = targetSize.height / imageSize.height
        }
        
        return scale
    }

    private func resizeImage(size: CGSize, scale: CGFloat) -> UIImage {
        
        // FIXME: Don't scale image up if smaller than target size.
        
        let imageSize = self.size
        
        let imageTargetSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        let imageTargetOrigin = CGPoint(
            x: (size.width - imageTargetSize.width) * 0.5,
            y: (size.height - imageTargetSize.height) * 0.5
        )
        
        let imageRect = CGRect(origin: imageTargetOrigin, size: imageTargetSize)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        draw(in: imageRect)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output!
    }
}
