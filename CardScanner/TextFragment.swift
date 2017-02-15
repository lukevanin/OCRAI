//
//  TextFragment.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

enum TextFragmentType: Int32 {
    case unknown = 0
    case person = 1
    case organization = 2
    case phoneNumber = 3
    case email = 4
    case url = 5
    case note = 6
}

private let entityName = "TextFragment"

extension TextFragment {
    
    var type: TextFragmentType {
        get {
            return TextFragmentType(rawValue: self.rawType) ?? .unknown
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    
    convenience init(type: TextFragmentType, value: String, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.type = type
        self.value = value
    }
}
