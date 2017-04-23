//
//  Field.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/25.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData

private let entityName = "Field"

extension Field: Actionable {
    
    var actionsTitle: String? {
        return String(describing: type)
    }
    
    var actionsDescription: String? {
        return self.value
    }
    
    var actions: [Action] {
        var actions = [Action]()

        // FIXME: Encapsulate actions in builder class for each field type
        
        switch type {
            
        case .email:
            if let value = value {
                if EmailAction.isAvailable {
                    actions.append(EmailAction(emailAddress: value))
                }
                
                actions.append(CopyTextAction(text: value))
            
                if let url = URL(string: value) {
                    actions.append(ShareAction(items: [url]))
                }
            }
            
        case .phoneNumber:
            
            if let value = value {
                
                let phoneAction = PhoneAction(phoneNumber: value)
                if phoneAction.canCallPhoneNumber {
                    actions.append(phoneAction)
                }
                
                if TextMessageAction.isAvailable {
                    actions.append(TextMessageAction(phoneNumber: value))
                }

                actions.append(CopyTextAction(text: value))
                actions.append(ShareAction(items: [value]))
            }
            
        case .url:
            if let value = value, let url = URL(string: value) {
                actions.append(WebPageAction(url: url))
                actions.append(CopyTextAction(text: value))
                actions.append(ShareAction(items: [url]))
            }
            
        default:
            if let value = value {
                actions.append(CopyTextAction(text: value))
                actions.append(ShareAction(items: [value]))
            }
        }
        
//        actions.append(
//            DeleteAction(
//                object: self,
//                context: self.managedObjectContext!
//            )
//        )
        
        return actions
    }
}

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
