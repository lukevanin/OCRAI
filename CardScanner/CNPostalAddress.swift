//
//  CNPostalAddress.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts

extension CNMutablePostalAddress {
    
    convenience init(addressDictionary: [String: String]) {
        self.init()
        update(addressDictionary: addressDictionary)
    }
    
    func update(addressDictionary: [String: String])  {

        if let street = addressDictionary[NSTextCheckingStreetKey] {
            self.street = street
        }
        
        if let city = addressDictionary[NSTextCheckingCityKey] {
            self.city = city
        }
        
        if let state = addressDictionary[NSTextCheckingStateKey] {
            self.state = state
        }
        
        if let postalCode = addressDictionary[NSTextCheckingZIPKey] {
            self.postalCode = postalCode
        }
        
        if let country = addressDictionary[NSTextCheckingCountryKey] {
            self.country = country
        }
    }
}
