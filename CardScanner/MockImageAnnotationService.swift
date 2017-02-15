//
//  MockImageAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct MockImageAnnotationService: ImageAnnotationService {
    
    let response: ImageAnnotationResponse?
    let error: Error?
    
    func annotate(request: ImageAnnotationRequest, completion: @escaping ImageAnnotationCompletion) -> Cancellable {
        let cancellable = MockCancellable()
        DispatchQueue.global().async {
            if !cancellable.cancelled {
                completion(self.response, self.error)
            }
        }
        return cancellable
    }
}
