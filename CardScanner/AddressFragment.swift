//
//  AddressFragment.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/21.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts
import CoreData

private let entityName = "AddressFragment"

extension AddressFragment {
    
    var address: CNPostalAddress {
        get {
            let address = CNMutablePostalAddress()
            
            if let street = self.street {
                address.street = street
            }
            
            if let city = self.city {
                address.city = city
            }
            
            if let postalCode = self.postalCode {
                address.postalCode = postalCode
            }
            
            if let country = self.country {
                address.country = country
            }
            
            if let countryCode = self.countryCode {
                address.isoCountryCode = countryCode
            }
            
            return address
        }
        set {
            self.street = newValue.street
            self.city = newValue.city
            self.postalCode = newValue.postalCode
            self.country = newValue.country
            self.countryCode = newValue.isoCountryCode
        }
    }
    
    convenience init(address: CNPostalAddress, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Cannot initialize entity \(entityName)")
        }
        self.init(entity: entity, insertInto: context)
        self.address = address
    }
}
