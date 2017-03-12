//
//  TextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts

struct Entity {
    var content: String
    var normalizedContent: String
    var annotations: [Annotation]
    init(content: String, normalizedContent: String? = nil, annotations: [Annotation]? = nil) {
        self.content = content
        self.normalizedContent = normalizedContent ?? content
        self.annotations = annotations ?? []
    }
}

struct TextAnnotationResponse {
    var personEntities: [Entity]
    var organizationEntities: [Entity]
    var addressEntities: [Entity]
    var phoneEntities: [Entity]
    var urlEntities: [Entity]
    var emailEntities: [Entity]
}

struct TextAnnotationRequest {
    let text: AnnotatedText
}

typealias TextAnnotationCompletion = (TextAnnotationResponse?, Error?) -> Void

protocol TextAnnotationService {
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion)
}
