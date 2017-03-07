//
//  UICollectionView+Photos.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/07.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import Photos

extension UICollectionView {
    func applyChanges(_ changes: PHFetchResultChangeDetails<PHAsset>, inSection section: Int, completion: ((Bool) -> Void)? = nil) {
        if changes.hasIncrementalChanges {
            performBatchUpdates({ [weak self] in
                
                if let indexSet = changes.removedIndexes {
                    let indexPaths = indexSet.map { IndexPath(item: $0, section: section) }
                    self?.deleteItems(at: indexPaths)
                }
                
                if let indexSet = changes.insertedIndexes {
                    let indexPaths = indexSet.map { IndexPath(item: $0, section: section) }
                    self?.insertItems(at: indexPaths)
                }
                
                if let indexSet = changes.changedIndexes {
                    let indexPaths = indexSet.map { IndexPath(item: $0, section: section) }
                    self?.reloadItems(at: indexPaths)
                }
                
                if changes.hasMoves {
                    changes.enumerateMoves {
                        self?.moveItem(
                            at: IndexPath(item: $0, section: 0),
                            to: IndexPath(item: $1, section: 0)
                        )
                    }
                }
            }, completion: completion)
        }
        else {
            reloadData()
        }
    }
}
