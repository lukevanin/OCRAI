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

import Foundation

public struct GoogleVisionAPI {
    
    public struct Vertex {
        public let x: Double?
        public let y: Double?
    }
    
    public struct BoundingPoly {
        public let vertices: [Vertex]
    }
    
    public struct EntityAnnotation {
        public let mid: String?
        public let locale: String?
        public let description: String?
        public let score: Double?
        public let confidence: Double?
        public let topicality: Double?
        public let boundingPoly: BoundingPoly?
    }
    
    public struct Status {
        public let code: Int
        public let message: String
    }
    
    public struct AnnotateImageResponse {
        public let textAnnotations: [EntityAnnotation]?
        public let labelAnnotations: [EntityAnnotation]?
        public let logoAnnotations: [EntityAnnotation]?
        public let error: Status?
    }
    
    public enum FeatureType {
        case logoDetection
        case labelDetection
        case textDetection
        case safeSearchDetection
        case imageProperties
    }
    
    public struct Feature {
        let type: FeatureType
        let maxResults: Int?
        public init(type: FeatureType, maxResults: Int? = nil) {
            self.type = type
            self.maxResults = maxResults
        }
    }
    
    public struct Image {
        let data: Data
        public init(data: Data) {
            self.data = data
        }
    }
    
    public struct AnnotationImageRequest {
        let image: Image
        let features: [Feature]
        public init(image: Image, features: [Feature]) {
            self.image = image
            self.features = features
        }
    }
    
    enum APIError: Error {
        case undefined
        case connection(Error)
        case http(Int)
        case content(Error)
        case parse
    }
    
    let key: String
    
    private let endpoint = "https://vision.googleapis.com/v1/images:annotate"
    private let session = URLSession.shared
    private let queue = DispatchQueue.main
    
    public typealias AnnotateCompletion = ([AnnotateImageResponse]?, Error?) -> Void
    
    public init(key: String) {
        self.key = key
    }

    @discardableResult public func annotate(requests: [AnnotationImageRequest], completion: @escaping AnnotateCompletion) -> URLSessionTask {
        let request = makeRequest(requests: requests)
        let task = session.dataTask(with: request) { (data, response, error) in
            self.queue.async {
                guard let data = data else {
                    // Missing data in response.
                    if let error = error {
                        // Connection error.
                        completion(nil, APIError.connection(error))
                    }
                    else {
                        // No connection error defined - try determine error from response code.
                        if let httpResponse = response as? HTTPURLResponse {
                            completion(nil, APIError.http(httpResponse.statusCode))
                        }
                        else {
                            completion(nil, APIError.undefined)
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
                        throw APIError.parse
                    }
                    
                    let responses = try entities.map { try AnnotateImageResponse(json: $0)  }
                    completion(responses, nil)
                }
                catch {
                    completion(nil, APIError.content(error))
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
        request.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        return request
    }
    
    private func makeBody(requests: [AnnotationImageRequest]) -> Data {
        
        let request = [
            "requests": requests.map { $0.json }
        ]
        
        return try! JSONSerialization.data(withJSONObject: request, options: [])
    }
}
