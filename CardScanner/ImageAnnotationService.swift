//
//  ImageAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

enum FeatureType {
    case text
    case logo
    case face
    case code
}

struct Feature {
    let type: FeatureType
    let limit: Int?
    
    init(type: FeatureType, limit: Int? = nil) {
        self.type = type
        self.limit = limit
    }
 }

struct ImageAnnotationRequest {
    let image: Data
    let features: [Feature]
}

struct Vertex {
    let x: Double
    let y: Double
}

struct Polygon {
    let vertices: [Vertex]
}

struct Annotation {
    let content: String
    let uri: String?
    let bounds: Polygon
}

struct ImageAnnotationResponse {
    let textAnnotations: [Annotation]
    let logoAnnotations: [Annotation]
    let faceAnnotations: [Annotation]
    let codeAnnotations: [Annotation]
}

typealias ImageAnnotationCompletion = (ImageAnnotationResponse?, Error?) -> Void

protocol ImageAnnotationService {
    func annotate(request: ImageAnnotationRequest, completion: @escaping ImageAnnotationCompletion) -> Cancellable
}

