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

private let entityName = "Location"

extension Location {
    
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

//extension Location: CustomStringConvertible {
//    var description: String {
//        var components = [String]()
//        
//        if let coordinate = coordinate {
//            components.append("Coordinates: \(coordinate)")
//        }
//        
//        if let throughfare = throughfare {
//            components.append("Throughfare: \(throughfare)")
//        }
//        
//        if let subThroughfare = subThroughfare {
//            components.append("Sub-throughfare: \(subThroughfare)")
//        }
//        
//        if let locality = locality {
//            components.append("Locality: \(locality)")
//        }
//        
//        if let subLocality = subLocality {
//            components.append("Sub-locality: \(subLocality)")
//        }
//        
//        if let administrativeArea = administrativeArea {
//            components.append("Administrative area: \(administrativeArea)")
//        }
//        
//        if let subAdministrativeArea = subAdministrativeArea {
//            components.append("Sub-administrative area: \(subAdministrativeArea)")
//        }
//        
//        if let postalCode = postalCode {
//            components.append("Postal code: \(postalCode)")
//        }
//        
//        if let countryCode = countryCode {
//            components.append("Country code: \(countryCode)")
//        }
//        
//        if let country = country {
//            components.append("Country: \(country)")
//        }
//        
//        return components.joined(separator: "\n")
//    }
//}
