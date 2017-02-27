//
//  GoogleNaturalLanguageAPI.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

public struct GoogleNaturalLanguageAPI {
    
    public enum DocumentType {
        case unspecified
        case plaintext
        case html
    }
    
    public enum EncodingType {
        case none
        case utf8
        case utf16
        case utf32
    }
    
    public struct Document {
        let type: DocumentType
        let language: String?
        let content: String
        public init(type: DocumentType, language: String? = nil, content: String) {
            self.type = type
            self.language = language
            self.content = content
        }
    }
    
    public struct AnalyzeEntitiesRequest {
        let encodingType: EncodingType
        let document: Document
        public init(encodingType: EncodingType, document: Document) {
            self.encodingType = encodingType
            self.document = document
        }
    }
    
    public enum EntityType {
        case unknown
        case person
        case location
        case organization
        case event
        case art
        case consumergoods
        case other
    }
    
    public enum EntityMentionType {
        case unknown
        case proper
        case common
    }
    
    public struct TextSpan {
        public let content: String
        public let beginOffset: Int
    }
    
    public struct EntityMention {
        public let type: EntityMentionType
        public let text: TextSpan
    }
    
    public struct Entity {
        public let name: String
        public let type: EntityType
        public let metadata: [String: String]
        public let salience: Double
        public let mentions: [EntityMention]
    }
    
    public struct AnalyzeEntitiesResponse {
        public let entities: [Entity]
        public let language: String
    }
    
    public enum APIError: Error {
        case parse
    }
    
    public typealias AnalyzeEntitiesCompletion = (AnalyzeEntitiesResponse?, Error?) -> Void
    
    public let key: String
    
    private let analyzeEntitiesEndpoint = "https://language.googleapis.com/v1beta1/documents:analyzeEntities"
    private let session = URLSession.shared
    
    public init(key: String) {
        self.key = key
    }
    
    public func analyzeEntities(request: AnalyzeEntitiesRequest, completion: @escaping AnalyzeEntitiesCompletion) -> URLSessionTask {
        
        let url = URL(string: "\(analyzeEntitiesEndpoint)?key=\(key)")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: request.json, options: [])
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let response = try AnalyzeEntitiesResponse(json: json)
                completion(response, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
 
 
