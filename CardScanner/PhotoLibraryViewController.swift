//
//  PhotoLibraryViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/05.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import Photos

private let imageCellIdentifier = "ImageCell"

private let unwindSegueIdentifier = "unwindSegue"

class PhotoLibraryViewController: UICollectionViewController, ImageSource {
    
    private let imageManager = PHImageManager.default()

    var selectedImageData: Data?
    
    private var result: PHFetchResult<PHAsset>?
    private var currentRequestID: PHImageRequestID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
    }
    
    private func loadPhotos() {
        
        // Create options.
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.wantsIncrementalChangeDetails = true
        
        // Issue request
        result = PHAsset.fetchAssets(with: .image, options: options)
        collectionView?.reloadData()
        
        // FIXME: Observe photo library for automatic updates.
    }
    
    // MARK: Collection delegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellIdentifier, for: indexPath) as! PhotoLibraryCell
        
        if let asset = result?[indexPath.item] {
            cell.configure(asset)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        cancelCurrentImageRequest()
        
        guard let asset = result?[indexPath.item] else {
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.version = .current
        
        currentRequestID = imageManager.requestImageData(
            for: asset,
            options: options) { (data, uti, orientation, info) in
                self.selectedImageData = data
                self.performSegue(withIdentifier: unwindSegueIdentifier, sender: nil)
        }
    }
    
    private func cancelCurrentImageRequest() {
        guard let requestID = currentRequestID else {
            return
        }
        imageManager.cancelImageRequest(requestID)
        currentRequestID = nil
    }
}
