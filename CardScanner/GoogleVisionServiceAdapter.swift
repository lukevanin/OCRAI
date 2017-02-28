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
    
    private func parseTextAnnotations(_ allEntities: [GoogleVisionAPI.EntityAnnotation]?) -> AnnotatedText {
        
        guard let allEntities = allEntities, let composite = allEntities.first?.description else {
            return AnnotatedText(text: "")
        }
        
        var output = AnnotatedText(text: composite)
        
        // First text entity contains the aggregate of all remaining entities.
        let components = allEntities.dropFirst()
        
        // Try to map the polygons of the individual entity components to the corresponding words in the composite string.
        
        var cursor = composite.startIndex..<composite.endIndex
        
        for component in components {
            if let componentText = component.description {
                
                guard let range = composite.range(of: componentText, options: [], range: cursor) else {
                    fatalError("Invalid data")
                }
                
                cursor = range.upperBound ..< composite.endIndex
                
                if let polygon = component.boundingPoly?.imageAnnotationPolygon() {
                    let annotation = Annotation(content: componentText, bounds: polygon)
                    output.addAnnotation(annotation, forRange: range)
                }
                
                
//                    let components = description.components(separatedBy: "\n").joined(separator: ", ")
//                    let polygon = entity.boundingPoly?.imageAnnotationPolygon() ?? Polygon(vertices: [])
//                    let annotation = Annotation(
//                        content: description,
//                        bounds: polygon
//                    )
//                    annotations.append(annotation)
            }
        }
        
        return output
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
