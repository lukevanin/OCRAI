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
