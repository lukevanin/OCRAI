//
//  Contact.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import Contacts

private let entityName = "Document"


extension Document {
    convenience init(imageData: Data, imageSize: CGSize, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.identifier = UUID().uuidString
        self.imageData = imageData as NSData
        self.imageSize = imageSize
        self.creationDate = Date(timeIntervalSinceNow: 0) as NSDate
    }
}

extension Document {
    
    var imageSize: CGSize {
        get {
            return CGSize(
                width: CGFloat(imageWidth),
                height: CGFloat(imageHeight)
            )
        }
        set {
            imageWidth = Int32(newValue.width)
            imageHeight = Int32(newValue.height)
        }
    }
    
    var title: String? {
        return titles.first
    }
    
    var titles: [String] {
        var output = [String]()
        
        let priorities: [FragmentType] = [
            .person,
            .organization,
            .url,
            .email,
            .phoneNumber,
            .address
        ]
        
        for priority in priorities {
            let fragment = allFragments.first { $0.type == priority }
            if let value = fragment?.value {
                output.append(value)
            }
        }
        
        return output
    }
    
    var primaryType: FragmentType {
        let personFragment = allFragments.first { $0.type == .person }
        let organizationFragment = allFragments.first { $0.type == .organization }
        return personFragment?.type ?? organizationFragment?.type ?? .unknown
    }
    
    var contact: CNContact {
        let contact = CNMutableContact()
        
        if let organization = fragments(ofType: .organization).first?.value {
            contact.organizationName = organization
            contact.contactType = .organization
        }
        
        if let name = fragments(ofType: .person).first?.value {
            contact.givenName = name
            contact.contactType = .person
        }
        
        let phoneNumbers = fragments(ofType: .phoneNumber)
        contact.phoneNumbers = phoneNumbers.flatMap({ $0.value }).map {
            CNLabeledValue(
                label: nil,
                value: CNPhoneNumber(stringValue: $0)
            )
        }
        
        let urlAddresses = fragments(ofType: .url)
        contact.urlAddresses = urlAddresses.flatMap({ $0.value }).map {
            CNLabeledValue(
                label: nil,
                value: $0 as NSString
            )
        }
        
        let emailAddresses = fragments(ofType: .email)
        contact.emailAddresses = emailAddresses.flatMap({ $0.value }).map {
            CNLabeledValue(
                label: nil,
                value: $0 as NSString
            )
        }
        
//        let postalAddresses = fragments(ofType: .address)
//        contact.postalAddresses = postalAddresses.flatMap({ $0.value }).map {
//            let address = CNMutablePostalAddress()
//
//            // FIXME: Detect address components in addres value
//            address
//            
//            CNLabeledValue(
//                label: nil,
//                value: $0 as NSString
//            )
//        }
    
        return contact
    }
    
    var allFragments: [Fragment] {
        return (fragments?.allObjects as? [Fragment]) ?? []
    }
    
    func fragments(ofType type: FragmentType) -> [Fragment] {
        return allFragments
            .filter() { $0.type == type }
            .sorted() { $0.ordinality < $1.ordinality }
    }
}

extension NSManagedObjectContext {
    func documents(withIdentifier identifier: String) throws -> [Document] {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier)
        return try fetch(request)
    }
}
