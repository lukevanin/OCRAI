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

//struct Coordinate {
//    let latitude: Double
//    let longitude: Double
//}
//
//struct Location {
//    var coordinate: Coordinate?
//    var throughfare: String?
//    var subThroughfare: String?
//    var locality: String?
//    var subLocality: String?
//    var administrativeArea: String?
//    var subAdministrativeArea: String?
//    var postalCode: String?
//    var countryCode: String?
//    var country: String?
//    
//    init() {
//    }
//}
//
//struct Fragment {
//    var label: String?
//    var content: String
//    
//    init(label: String? = nil, content: String) {
//        self.label = label
//        self.content = content
//    }
//}
//
//struct Document {
//    var image: Data
//    var faces: [Data]
//    var logos: [Data]
//    var names: [String]
//    var organizations: [String]
//    var phoneNumbers: [Fragment]
//    var urlAddresses: [Fragment]
//    var emailAddresses: [Fragment]
//    var locations: [Location]
//    var notes: [String]
//    
//    init(image: Data) {
//        self.image = image
//        self.faces = []
//        self.logos = []
//        self.names = []
//        self.organizations = []
//        self.phoneNumbers = []
//        self.urlAddresses = []
//        self.emailAddresses = []
//        self.locations = []
//        self.notes = []
//    }
//}

/*
 

 */



/*

// MARK: String


extension Fragment: CustomStringConvertible {
    var description: String {
        if let label = label {
            return "[\(label)] \(content)"
        }
        else {
            return content
        }
    }
}

extension Document: CustomStringConvertible {
    var description: String {
        var components = [String]()
        
        components.append(contentsOf: names.map {
            "Person:\n\($0)\n"
        })
        
        components.append(contentsOf: organizations.map {
            "Organization:\n\($0)\n"
        })
        
        components.append(contentsOf: phoneNumbers.map {
            "Phone Number:\n\($0)\n"
        })
        
        components.append(contentsOf: urlAddresses.map {
            "URL:\n\($0)\n"
        })
        
        components.append(contentsOf: emailAddresses.map {
            "Email:\n\($0)\n"
        })
        
        components.append(contentsOf: locations.map {
            "Location:\n\($0)\n"
        })
        
        components.append(contentsOf: notes.map {
            "Notes:\n\($0)\n"
        })
        
        return components.joined(separator: "\n")
    }
}
 
 */
