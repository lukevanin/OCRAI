//
//  MockTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct MockTextAnnotationService: TextAnnotationService {
    
    let response: TextAnnotationResponse?
    let error: Error?
    
    func annotate(request: TextAnnotationRequest, completion: @escaping (TextAnnotationResponse?, Error?) -> Void) {
        let cancellable = MockCancellable()
        DispatchQueue.global().async {
            if !cancellable.cancelled {
                completion(self.response, self.error)
            }
        }
    }
}
