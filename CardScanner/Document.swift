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

private let entityName = "Document"


extension Document {
    convenience init(imageData: Data, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.identifier = UUID().uuidString
        self.imageData = imageData as NSData
        self.creationDate = Date(timeIntervalSinceNow: 0) as NSDate
    }
}

extension NSManagedObjectContext {
    func documents(withIdentifier identifier: String) throws -> [Document] {
        let request: NSFetchRequest<Document> = Document.fetchRequest()
        request.predicate = NSPredicate(format: "identifier == %@", identifier)
        return try fetch(request)
    }
}
