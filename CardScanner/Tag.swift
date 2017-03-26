//
//  Tag.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/25.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

private let entityName = "Tag"

extension Tag {
    
    var type: FieldType {
        get {
            return FieldType(rawValue: Int(self.rawType)) ?? .unknown
        }
        set {
            self.rawType = Int32(newValue.rawValue)
        }
    }
    
    var range: NSRange {
        get {
            return NSRange(location: Int(location), length: Int(length))
        }
        set {
            location = Int32(newValue.location)
            length = Int32(newValue.length)
        }
    }
    
    convenience init(type: FieldType, text: String, range: NSRange, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.type = type
        self.text = text
        self.range = range
    }
}
