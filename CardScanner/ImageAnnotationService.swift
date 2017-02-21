//
//  ImageAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

struct FeatureType: OptionSet {
    let rawValue: Int
    static let text = FeatureType(rawValue: 1 << 0)
    static let logo = FeatureType(rawValue: 1 << 1)
    static let face = FeatureType(rawValue: 1 << 2)
    static let code = FeatureType(rawValue: 1 << 3)
}

struct ImageAnnotationRequest {
    let image: Data
    let feature: FeatureType
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

