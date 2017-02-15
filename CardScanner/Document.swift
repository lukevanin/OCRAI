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

//@property (nonatomic, readonly, copy, nullable) NSString *name; // eg. Apple Inc.
//@property (nonatomic, readonly, copy, nullable) NSString *thoroughfare; // street name, eg. Infinite Loop
//@property (nonatomic, readonly, copy, nullable) NSString *subThoroughfare; // eg. 1
//@property (nonatomic, readonly, copy, nullable) NSString *locality; // city, eg. Cupertino
//@property (nonatomic, readonly, copy, nullable) NSString *subLocality; // neighborhood, common name, eg. Mission District
//@property (nonatomic, readonly, copy, nullable) NSString *administrativeArea; // state, eg. CA
//@property (nonatomic, readonly, copy, nullable) NSString *subAdministrativeArea; // county, eg. Santa Clara
//@property (nonatomic, readonly, copy, nullable) NSString *postalCode; // zip code, eg. 95014
//@property (nonatomic, readonly, copy, nullable) NSString *ISOcountryCode; // eg. US
//@property (nonatomic, readonly, copy, nullable) NSString *country; // eg. United States
//@property (nonatomic, readonly, copy, nullable) NSString *inlandWater; // eg. Lake Tahoe
//@property (nonatomic, readonly, copy, nullable) NSString *ocean; // eg. Pacific Ocean
//@property (nonatomic, readonly, copy, nullable) NSArray<NSString *> *areasOfInterest; // eg. Golden Gate Park

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


extension Document {
    convenience init(imageData: Data, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.identifier = UUID().uuidString
        self.imageData = imageData as NSData
    }
}


/*

// MARK: String

extension CLLocationCoordinate: CustomStringConvertible {
    var description: String {
        return String(format: "lat: %0.4f, lng: %0.4f", latitude, longitude)
    }
}


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
