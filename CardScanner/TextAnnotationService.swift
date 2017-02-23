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
    var offset: Int?
    var content: String
    init(offset: Int? = nil, content: String) {
        self.offset = offset
        self.content = content
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
    let content: String
}

typealias TextAnnotationCompletion = (TextAnnotationResponse?, Error?) -> Void

protocol TextAnnotationService {
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable
}
