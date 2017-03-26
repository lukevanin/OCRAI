//
//  Field.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/25.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

private let entityName = "Field"

extension Field {
    
    var type: FieldType {
        get {
            return FieldType(rawValue: Int(self.rawType)) ?? .unknown
        }
        set {
            self.rawType = Int32(newValue.rawValue)
        }
    }
    
    convenience init(type: FieldType, value: String, label: String? = nil, ordinality: Int32 = 0, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.type = type
        self.value = value
        self.label = label
        self.ordinality = ordinality
    }
}
