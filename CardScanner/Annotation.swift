//
//  FragmentAnnotation.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

private let entityName = "Annotation"

extension Annotation {
    
    var range: NSRange {
        get {
            return NSRange(location: Int(location), length: Int(length))
        }
        set {
            location = Int32(newValue.location)
            length = Int32(newValue.length)
        }
    }
    
    convenience init(range: NSRange, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.range = range
    }
}

extension Annotation {
    
    var points: [CGPoint] {
        return allVertices().map {
            $0.point
        }
    }
    
    func allVertices() -> [Vertex] {
        var output = [Vertex]()
        
        if let vertices = self.vertices?.array as? [Vertex] {
            output.append(contentsOf: vertices)
        }
        
        return output
    }
}
