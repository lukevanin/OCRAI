//
//  JSON.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

// MARK: Serialize JSON

extension GoogleVisionAPI.Image {
    var json: Any {
        return [
            "content": data.base64EncodedString(options: [])
        ]
    }
}

extension GoogleVisionAPI.FeatureType {
    var json: Any {
        switch self {
        case .logoDetection:
            return "LOGO_DETECTION"
            
        case .labelDetection:
            return "LABEL_DETECTION"
            
        case .textDetection:
            return "TEXT_DETECTION"
            
        case .safeSearchDetection:
            return "SAFE_SEARCH_DETECTION"
            
        case .imageProperties:
            return "IMAGE_PROPERTIES"
        }
    }
}

extension GoogleVisionAPI.Feature {
    var json: Any {
        var output = [String: Any]()
        output["type"] = type.json
        
        if let maxResults = maxResults {
            output["maxResults"] = maxResults
        }
        
        return output
    }
}

extension GoogleVisionAPI.AnnotationImageRequest {
    var json: Any {
        return [
            "image": image.json,
            "features": features.map { $0.json }
        ]
    }
}

// MARK: JSON Deserialization

extension GoogleVisionAPI.Status {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any],
            let code = entity["code"] as? Int,
            let message = entity["message"] as? String
            else {
                throw GoogleVisionAPI.APIError.parse
        }
        self.code = code
        self.message = message
    }
}

extension GoogleVisionAPI.Vertex {
    init(json: Any) throws {
        let entity = json as? [String: Any]
        self.x = entity?["x"] as? Double
        self.y = entity?["y"] as? Double
    }
}

extension GoogleVisionAPI.BoundingPoly {
    init(json: Any) throws {
        guard
            let entities = json as? [String: Any],
            let vertices = entities["vertices"] as? [Any]
            else {
                throw GoogleVisionAPI.APIError.parse
        }
        self.vertices = try vertices.map { try GoogleVisionAPI.Vertex(json: $0) }
    }
}

extension GoogleVisionAPI.EntityAnnotation {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any]
            else {
                throw GoogleVisionAPI.APIError.parse
        }
        self.mid = entity["mid"] as? String
        self.locale = entity["locale"] as? String
        self.description = entity["description"] as? String
        self.score = entity["score"] as? Double
        self.confidence = entity["confidence"] as? Double
        self.topicality = entity["topicality"] as? Double
        
        if let json = entity["boundingPoly"] {
            self.boundingPoly = try GoogleVisionAPI.BoundingPoly(json: json)
        }
        else {
            self.boundingPoly = nil
        }
    }
}

extension GoogleVisionAPI.AnnotateImageResponse {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any]
            else {
                throw GoogleVisionAPI.APIError.parse
        }
        
        if let textAnnotations = entity["textAnnotations"] as? [Any] {
            self.textAnnotations = try textAnnotations.map {
                try GoogleVisionAPI.EntityAnnotation(json: $0)
            }
        }
        else {
            self.textAnnotations = nil
        }
        
        if let labelAnnotations = entity["labelAnnotations"] as? [Any] {
            self.labelAnnotations = try labelAnnotations.map {
                try GoogleVisionAPI.EntityAnnotation(json: $0)
            }
        }
        else {
            self.labelAnnotations = nil
        }
        
        if let logoAnnotations = entity["logoAnnotations"] as? [Any] {
            self.logoAnnotations = try logoAnnotations.map {
                try GoogleVisionAPI.EntityAnnotation(json: $0)
            }
        }
        else {
            self.logoAnnotations = nil
        }
        
        if let json = entity["error"] as? [Any] {
            self.error = try GoogleVisionAPI.Status(json: json)
        }
        else {
            self.error = nil
        }
    }
}
