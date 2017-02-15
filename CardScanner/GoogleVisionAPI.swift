//
//  GoogleVisionAPI.swift
//  Vision
//
//  Created by Luke Van In on 2017/01/31.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  Implementation of Google Vision API
//  https://cloud.google.com/vision/docs/reference/rest/v1/images/annotate
//
/*

import Foundation


struct Vertex {
    let x: Double?
    let y: Double?
}

struct BoundingPoly {
    let vertices: [Vertex]
}

struct EntityAnnotation {
    let mid: String?
    let locale: String?
    let description: String?
    let score: Double?
    let confidence: Double?
    let topicality: Double?
    let boundingPoly: BoundingPoly?
}

struct Status {
    let code: Int
    let message: String
}

struct AnnotateImageResponse {
    let textAnnotations: [EntityAnnotation]?
    let labelAnnotations: [EntityAnnotation]?
    let logoAnnotations: [EntityAnnotation]?
    let error: Status?
}

enum Image {
    case content(Data)
    case source(URL)
}

enum FeatureType {
    case logoDetection
    case labelDetection
    case textDetection
    case safeSearchDetection
    case imageProperties
}

struct Feature {
    let type: FeatureType
    let maxResults: Int?
    
    init(type: FeatureType, maxResults: Int? = nil) {
        self.type = type
        self.maxResults = nil
    }
}

struct AnnotationImageRequest {
    let image: Image
    let features: [Feature]
}

// MARK: Serialize JSON

extension Image {
    var json: Any {
        switch self {
        case .content(let data):
            return [
                "content": data.base64EncodedString(options: [])
            ]
            
        case .source(let url):
            return [
                "source": [
                    "gcsImageUri": url.absoluteString
                    ]
            ]
        }
    }
}

extension FeatureType {
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

extension Feature {
    var json: Any {
        var output = [String: Any]()
        output["type"] = type.json
        
        if let maxResults = maxResults {
            output["maxResults"] = maxResults
        }
        
        return output
    }
}

extension AnnotationImageRequest {
    var json: Any {
        return [
            "image": image.json,
            "features": features.map { $0.json }
        ]
    }
}

// MARK: JSON Deserialization

extension Status {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any],
            let code = entity["code"] as? Int,
            let message = entity["message"] as? String
        else {
            throw ContentError.parse
        }
        self.code = code
        self.message = message
    }
}

extension Vertex {
    init(json: Any) throws {
        let entity = json as? [String: Any]
        self.x = entity?["x"] as? Double
        self.y = entity?["y"] as? Double
    }
}

extension BoundingPoly {
    init(json: Any) throws {
        guard
            let entities = json as? [String: Any],
            let vertices = entities["vertices"] as? [Any]
        else {
            throw ContentError.parse
        }
        self.vertices = try vertices.map { try Vertex(json: $0) }
    }
}

extension EntityAnnotation {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any]
        else {
            throw ContentError.parse
        }
        self.mid = entity["mid"] as? String
        self.locale = entity["locale"] as? String
        self.description = entity["description"] as? String
        self.score = entity["score"] as? Double
        self.confidence = entity["confidence"] as? Double
        self.topicality = entity["topicality"] as? Double
        
        if let json = entity["boundingPoly"] {
            self.boundingPoly = try BoundingPoly(json: json)
        }
        else {
            self.boundingPoly = nil
        }
    }
}

extension AnnotateImageResponse {
    init(json: Any) throws {
        guard
            let entity = json as? [String: Any]
        else {
            throw ContentError.parse
        }
        
        if let textAnnotations = entity["textAnnotations"] as? [Any] {
            self.textAnnotations = try textAnnotations.map { try EntityAnnotation(json: $0) }
        }
        else {
            self.textAnnotations = nil
        }

        if let labelAnnotations = entity["labelAnnotations"] as? [Any] {
            self.labelAnnotations = try labelAnnotations.map { try EntityAnnotation(json: $0) }
        }
        else {
            self.labelAnnotations = nil
        }
        
        if let logoAnnotations = entity["logoAnnotations"] as? [Any] {
            self.logoAnnotations = try logoAnnotations.map { try EntityAnnotation(json: $0) }
        }
        else {
            self.logoAnnotations = nil
        }
        
        if let json = entity["error"] as? [Any] {
            self.error = try Status(json: json)
        }
        else {
            self.error = nil
        }
    }
}

struct GoogleVisionAPI {
    
    let key: String
    
    private let endpoint = "https://vision.googleapis.com/v1/images:annotate"
    private let session = URLSession.shared
    private let queue = DispatchQueue.main
    
    typealias AnnotateCompletion = ([AnnotateImageResponse]?, AnnotationError?) -> Void

    @discardableResult func annotate(requests: [AnnotationImageRequest], completion: @escaping AnnotateCompletion) -> URLSessionTask {
        let request = makeRequest(requests: requests)
        let task = session.dataTask(with: request) { (data, response, error) in
            self.queue.async {
                guard let data = data else {
                    // Missing data in response.
                    if let error = error {
                        // Connection error.
                        completion(nil, .connection(error))
                    }
                    else {
                        // No connection error defined - try determine error from response code.
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(nil, .http(httpResponse.statusCode))
                        }
                        else {
                            completion(nil, .undefined)
                        }
                    }
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard
                        let entity = json as? [String: Any],
                        let entities = entity["responses"] as? [Any]
                    else {
                        throw ContentError.parse
                    }
                    
                    let responses = try entities.map { try AnnotateImageResponse(json: $0)  }
                    completion(responses, nil)
                }
                catch {
                    completion(nil, .content(error))
                }
            }
        }
        task.resume()
        return task
    }
    
    private func makeRequest(requests: [AnnotationImageRequest]) -> URLRequest {
        let requestURL = URL(string: "\(endpoint)?key=\(key)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        request.httpBody = makeBody(requests: requests)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func makeBody(requests: [AnnotationImageRequest]) -> Data {
        
        let request = [
            "requests": requests.map { $0.json }
        ]
        
        return try! JSONSerialization.data(withJSONObject: request, options: [])
    }
}
*/
