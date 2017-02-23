//
//  TextFragment.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

enum FragmentType: Int32 {
    case unknown = 0
    case person = 1
    case organization = 2
    case phoneNumber = 3
    case email = 4
    case url = 5
    case note = 6
    case address = 7
    case face = 8
    case logo = 9
}

extension FragmentType: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown:
            return "Unknown"
            
        case .person:
            return "Person"
            
        case .organization:
            return "Organization"
            
        case .phoneNumber:
            return "Phone number"
            
        case .email:
            return "Email"
            
        case .url:
            return "URL"
            
        case .note:
            return "Note"
            
        case .address:
            return "Address"
            
        case .face:
            return "Face"
            
        case .logo:
            return "Logo"
        }
    }
}

private let entityName = "Fragment"

extension Fragment {
    
    var type: FragmentType {
        get {
            return FragmentType(rawValue: self.rawType) ?? .unknown
        }
        set {
            self.rawType = newValue.rawValue
        }
    }
    
    convenience init(type: FragmentType, value: String, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.type = type
        self.value = value
    }
}
