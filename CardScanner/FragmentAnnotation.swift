//
//  FragmentAnnotation.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

private let entityName = "FragmentAnnotation"

extension FragmentAnnotation {
    convenience init(context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
    }
}

extension FragmentAnnotation {
    func allVertices() -> [FragmentAnnotationVertex] {
        var output = [FragmentAnnotationVertex]()
        
        if let vertices = self.vertices?.array as? [FragmentAnnotationVertex] {
            output.append(contentsOf: vertices)
        }
        
        return output
    }
}
