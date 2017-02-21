//
//  GoogleVisionServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import GoogleVisionAPI

extension ImageAnnotationRequest {
    
    typealias Feature = GoogleVisionAPI.Feature
    
    func googleVisionRequest() -> GoogleVisionAPI.AnnotationImageRequest {
        
        var features = [Feature]()
        
        if feature.contains(.text) {
            features.append(Feature(type: .textDetection))
        }
        
        // FIXME: Annotate faces, logo, and machine code.
        
        return GoogleVisionAPI.AnnotationImageRequest(
            image: GoogleVisionAPI.Image(
                data: image
            ),
            features: features
        )
    }
}

extension GoogleVisionAPI.Vertex {
    func imageAnnotationVertex() -> Vertex? {
        guard let x = self.x, let y = self.y else {
            return nil
        }
        return Vertex(
            x: x,
            y: y
        )
    }
}

extension GoogleVisionAPI.BoundingPoly {
    func imageAnnotationPolygon() -> Polygon {
        var vertices = [Vertex]()
        
        for vertex in self.vertices {
            if let v = vertex.imageAnnotationVertex() {
                vertices.append(v)
            }
        }
        
        return Polygon(
            vertices: vertices
        )
    }
}

extension GoogleVisionAPI.AnnotateImageResponse {
    func imageAnnotationResponse() -> ImageAnnotationResponse {
        return ImageAnnotationResponse(
            textAnnotations: parseTextAnnotations(textAnnotations),
            logoAnnotations: [], // FIXME: Parse logo
            faceAnnotations: [], // FIXME: Parse face
            codeAnnotations: [] // FIXME: Parse machine code
        )
    }
    
    private func parseTextAnnotations(_ entities: [GoogleVisionAPI.EntityAnnotation]?) -> [Annotation] {
        var annotations = [Annotation]()
        
        if let entities = entities {
            for entity in entities {
                if let description = entity.description {
                    let components = description.components(separatedBy: "\n").joined(separator: ", ")
                    let polygon = entity.boundingPoly?.imageAnnotationPolygon() ?? Polygon(vertices: [])
                    let annotation = Annotation(
                        content: components,
                        bounds: polygon
                    )
                    annotations.append(annotation)
                }
            }
        }
        
        return annotations
    }
}

struct GoogleVisionServiceAdapter: ImageAnnotationService {
    let service: GoogleVisionAPI
    func annotate(request: ImageAnnotationRequest, completion: @escaping ImageAnnotationCompletion) -> Cancellable {
        let serviceRequest = request.googleVisionRequest()
        return service.annotate(requests: [serviceRequest]) { (response, error) in
            let output = response?.first?.imageAnnotationResponse()
            completion(output, error)
        }
    }
}
