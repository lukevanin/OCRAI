//
//  TextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts

struct Entity<ContentType> {
    var offset: Int?
    var content: ContentType
    init(offset: Int? = nil, content: ContentType) {
        self.offset = offset
        self.content = content
    }
}

struct TextAnnotationResponse {
    var personEntities: [Entity<String>]
    var organizationEntities: [Entity<String>]
    var addressEntities: [Entity<CNPostalAddress>]
    var phoneEntities: [Entity<String>]
    var urlEntities: [Entity<URL>]
    var emailEntities: [Entity<URL>]
}

struct TextAnnotationRequest {
    let content: String
}

typealias TextAnnotationCompletion = (TextAnnotationResponse?, Error?) -> Void

protocol TextAnnotationService {
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable
}
