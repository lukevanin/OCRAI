//
//  FragmentAnnotationVertex.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private let entityName = "FragmentAnnotationVertex"

extension FragmentAnnotationVertex {
    
    var point: CGPoint {
        get {
            return CGPoint(x: self.x, y: self.y)
        }
        set {
            self.x = Double(newValue.x)
            self.y = Double(newValue.y)
        }
    }
    
    convenience init(x: Double, y: Double, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.x = x
        self.y = y
    }
}
