//
//  CoreLocationAddressResolutionService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

extension CLGeocoder: Cancellable {
    func cancel() {
        cancelGeocode()
    }
}

struct CoreLocationAddressResolutionService: AddressResolutionService {
    func resolve(entity: String, completion: @escaping AddressResolutionCompletion) -> Cancellable {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(entity) { (places, error) in
            completion(places, error)
        }
        return geocoder
    }
}
