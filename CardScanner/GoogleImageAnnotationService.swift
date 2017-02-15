//
//  GoogleImageAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct GoogleImageAnnotationService: ImageAnnotationService {
    func annotate(request: ImageAnnotationRequest, completion: @escaping ImageAnnotationCompletion) -> Cancellable {
        fatalError("not implemented")
//        let api = GoogleVisionAPI(key: googleKey)
//        api.annotate(requests: [request]) { (responses, error) in
//            let text = responses?.first?.textAnnotations?.first?.description
//            completion(text)
//        }
    }
}
