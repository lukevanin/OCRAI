//
//  ImageFragment.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

enum ImageFragmentType: Int32 {
    case unknown = 0
    case person = 1
    case logo = 2
}

private let entityName = "ImageFragment"

extension ImageFragment {
    
    var type: ImageFragmentType {
        get {
            return ImageFragmentType(rawValue: self.rawType) ?? .unknown
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    
    convenience init(type: ImageFragmentType, imageData: Data, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.type = type
        self.imageData = imageData as NSData
    }
}
