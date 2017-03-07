//
//  LibraryCollectionViewCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/05.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryCell: UICollectionViewCell {
    
    let imageManager = PHImageManager.default()
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageRequestID: PHImageRequestID?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageRequest()
        imageView.image = nil
    }
    
    func cancelImageRequest() {
        if let requestID = imageRequestID {
            imageManager.cancelImageRequest(requestID)
        }
        imageRequestID = nil
    }
    
    func configure(_ asset: PHAsset) {
        cancelImageRequest()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.version = .current
        options.isNetworkAccessAllowed = true
        
        imageRequestID = imageManager.requestImage(
            for: asset,
            targetSize: self.bounds.size,
            contentMode: .aspectFit,
            options: options
        ) { (image, info) in
            
            guard
                let info = info,
                let requestID = info[PHImageResultRequestIDKey] as? NSNumber,
                PHImageRequestID(requestID.intValue) == self.imageRequestID
            else {
                return
            }
            
            if let cancelled = info[PHImageCancelledKey] as? NSNumber, cancelled.boolValue == true {
                print("Image cancelled");
                return
            }
            
            if let error = info[PHImageErrorKey] as? NSError {
                print("Error loading image: \(error)")
                return
            }
            
            self.imageView.image = image
        }
    }
}
