//
//  GoogleVisionServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData
import GoogleVisionAPI

struct GoogleVisionServiceAdapter: ImageAnnotationService {
    
    let service: GoogleVisionAPI
    
    func annotate(content: Document, completion: @escaping ImageAnnotationServiceCompletion) {
        
        DispatchQueue.main.async { [content, service] in
            
            guard let imageData = content.imageData else {
                completion(true, nil)
                return
            }
        
            let serviceRequest = GoogleVisionAPI.AnnotationImageRequest(
                image: GoogleVisionAPI.Image(
                    data: imageData
                ),
                features: [
                    GoogleVisionAPI.Feature(type: .textDetection)
                ]
            )
            
            service.annotate(requests: [serviceRequest]) { (responses, error) in
                
                guard let response = responses?.first else {
                    completion(false, error)
                    return
                }

                DispatchQueue.main.async {
                    self.parseResponse(response: response, content: content)
                    completion(true, nil)
                }
            }
        }
    }
    
    func parseResponse(response: GoogleVisionAPI.AnnotateImageResponse, content: Document) {
        
        guard let allEntities = response.textAnnotations, let rawText = allEntities.first?.description else {
            return
        }

        let allText = rawText.components(separatedBy: "\n").joined(separator: ", ")
        content.text = allText
        
        let entities = allEntities.dropFirst()
        var cursor = allText.startIndex ..< allText.endIndex
        
        entities.forEach { entity in
            
            guard let text = entity.description else {
                return
            }
            
            guard let range = allText.range(of: text, options: [], range: cursor), let vertices = entity.boundingPoly?.vertices else {
                fatalError("Invalid data")
            }
            
            let points = vertices.flatMap { (vertex) -> CGPoint? in
                guard let x = vertex.x, let y = vertex.y else {
                    return nil
                }
                return CGPoint(x: x, y: y)
            }
            
            content.annotate(
                at: allText.convertRange(range),
                vertices: points
            )
            
            cursor = range.upperBound ..< allText.endIndex
        }
    }
}
