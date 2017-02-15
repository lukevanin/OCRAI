//
//  TextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct Entity {
    let offset: Int
    let content: String
}

struct TextAnnotationResponse {
    let personEntities: [Entity]
    let organizationEntities: [Entity]
    let addressEntites: [Entity]
    let phoneEntities: [Entity]
    let urlEntities: [Entity]
    let emailEntities: [Entity]
    let atEntities: [Entity]
}

struct TextAnnotationRequest {
    let content: String
}

typealias TextAnnotationCompletion = (TextAnnotationResponse?, Error?) -> Void

protocol TextAnnotationService {
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable
}
