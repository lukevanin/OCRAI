//
//  AddressResolutionService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/10.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

typealias AddressResolutionCompletion = ([CLPlacemark]?, Error?) -> Void

protocol AddressResolutionService {
    func resolve(entity: String, completion: @escaping AddressResolutionCompletion) -> Cancellable
}
