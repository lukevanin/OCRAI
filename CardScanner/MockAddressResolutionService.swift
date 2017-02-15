//
//  MockAddressResolutionService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation

struct MockAddressResolutionService: AddressResolutionService {
    
    let response: Location?
    let error: Error?
    
    func resolve(entity: Entity, completion: @escaping AddressResolutionCompletion) -> Cancellable {
        let cancellable = MockCancellable()
        DispatchQueue.global().async {
            if !cancellable.cancelled {
                completion(self.response, self.error)
            }
        }
        return cancellable
    }
}
