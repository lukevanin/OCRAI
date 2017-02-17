//
//  Location.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

private let entityName = "LocationFragment"

extension LocationFragment {
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    convenience init(placemark: CLPlacemark, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.administrativeArea = placemark.administrativeArea
        self.subAdministrativeArea = placemark.subAdministrativeArea
        self.locality = placemark.locality
        self.subLocality = placemark.subLocality
        self.throughfare = placemark.thoroughfare
        self.subThroughfare = placemark.subThoroughfare
        self.postalCode = placemark.postalCode
        self.countryCode = placemark.isoCountryCode
        self.country = placemark.country
        
        if let location = placemark.location {
            self.coordinate = location.coordinate
        }
    }
}


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

extension LocationFragment {
    var address: String {
        var components = [String]()
        
        if let throughfare = throughfare {
            if let subThroughfare = subThroughfare {
                components.append("\(subThroughfare) \(throughfare)")
            }
            else {
                components.append(throughfare)
            }
        }
        
        if let subLocality = subLocality {
            components.append(subLocality)
        }
        
        if let locality = locality {
            components.append(locality)
        }
        
        if let subAdministrativeArea = subAdministrativeArea {
            components.append(subAdministrativeArea)
        }
        
        if let administrativeArea = administrativeArea {
            components.append(administrativeArea)
        }
        
        if let postalCode = postalCode {
            components.append(postalCode)
        }
        
        if let country = country {
            components.append(country)
        }
        
        return components.joined(separator: "\n")
    }
}

//extension CLLocationCoordinate: CustomStringConvertible {
//    var description: String {
//        return String(format: "lat: %0.4f, lng: %0.4f", latitude, longitude)
//    }
//}
