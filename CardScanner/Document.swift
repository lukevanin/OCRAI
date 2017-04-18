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

extension NSManagedObjectContext {
    func documents(withIdentifier identifier: String) throws -> [Document] {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier)
        return try fetch(request)
    }
}

extension Document {
    
    var imageData: Data? {
        return rawImageData as? Data
    }

    convenience init(imageData: Data, imageSize: CGSize, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.identifier = UUID().uuidString
        self.rawImageData = imageData as NSData
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
        
        let priorities = FieldType.all
        
        for priority in priorities {
            if let field = fields(ofType: priority).first, let value = field.value {
                output.append(value)
            }
        }
        
        return output
    }
    
    var primaryType: FieldType {
        let personFragment = allFields.first { $0.type == .person }
        let organizationFragment = allFields.first { $0.type == .organization }
        return personFragment?.type ?? organizationFragment?.type ?? .unknown
    }
    
    var contact: CNContact {
        let builder = ContactBuilder()
        builder.addOrganization(fields: fields(ofType: .organization))
        builder.addPerson(fields: fields(ofType: .person))
        builder.addPhoneNumbers(fields: fields(ofType: .phoneNumber))
        builder.addURLAddresses(fields: fields(ofType: .url))
        builder.addEmailAddresses(fields: fields(ofType: .email))
        return builder.build()
    }
    
    var allAnnotations: [Annotation] {
        return (annotations?.allObjects as? [Annotation]) ?? []
    }
    
    var allFields: [Field] {
        return (fields?.array as? [Field]) ?? []
    }
    
    var allTags: [Tag] {
        return (tags?.array as? [Tag]) ?? []
    }
    
    var allPostalAddresses: [PostalAddress] {
        return (addresses?.array as? [PostalAddress]) ?? []
    }
    
    func fields(ofType type: FieldType) -> [Field] {
        return allFields
            .filter() { $0.type == type }
            .sorted() { $0.ordinality < $1.ordinality }
    }
}

extension Document {
    
    func annotate(at range: NSRange, vertices: [CGPoint]) {
        
        guard let context = self.managedObjectContext else {
            return
        }
        
        let annotation = Annotation(
            range: range,
            context: context
        )
        addToAnnotations(annotation)
    }
    
    func annotate(type: FieldType, text: String, at range: NSRange) {
        
        guard let context = self.managedObjectContext else {
            return
        }
        
        let tag = Tag(
            type: type,
            text: text,
            range: range,
            context: context
        )
        addToTags(tag)
    }
    
    func annotate(address: CNPostalAddress, at range: NSRange) {
        
        guard let context = self.managedObjectContext else {
            return
        }
        
        let postalAddress = PostalAddress(address: address, context: context)
        addToAddresses(postalAddress)
    }
}
