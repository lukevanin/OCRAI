//
//  GoogleNaturalLanguageAPI.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

/*

import Foundation

// Types

enum DocumentType {
    case unspecified
    case plaintext
    case html
}

enum EncodingType {
    case none
    case utf8
    case utf16
    case utf32
}

struct Document {
    let type: DocumentType
    let language: String?
    let content: String
    
    init(type: DocumentType, language: String? = nil, content: String) {
        self.type = type
        self.language = language
        self.content = content
    }
}

struct AnalyzeEntitiesRequest {
    let encodingType: EncodingType
    let document: Document
}

enum EntityType {
    case unknown
    case person
    case location
    case organization
    case event
    case art
    case consumergoods
    case other
}

enum EntityMentionType {
    case unknown
    case proper
    case common
}

struct TextSpan {
    let content: String
    let beginOffset: Int
}

struct EntityMention {
    let type: EntityMentionType
    let text: TextSpan
}

struct Entity {
    let name: String
    let type: EntityType
    let metadata: [String: String]
    let salience: Double
    let mentions: [EntityMention]
}

struct AnalyzeEntitiesResponse {
    let entities: [Entity]
    let language: String
}


// JSON

extension EncodingType {
    var json: String {
        switch self {
        case .none:
            return "NONE"
            
        case .utf8:
            return "UTF8"
            
        case .utf16:
            return "UTF16"
            
        case .utf32:
            return "UTF32"
        }
    }
}

extension DocumentType {
    var json: String {
        switch self {
        case .unspecified:
            return "TYPE_UNSPECIFIED"
            
        case .plaintext:
            return "PLAIN_TEXT"
            
        case .html:
            return "HTML"
        }
    }
}

extension Document {
    var json: [String: Any] {
        var output = [String: Any]()
        output["type"] = type.json
        output["content"] = content
        
        if let language = language {
            output["language"] = language
        }
        
        return output
    }
}

extension AnalyzeEntitiesRequest {
    var json: [String: Any] {
        return [
            "document": document.json,
            "encodingType": encodingType.json
        ]
    }
}



// Natural language API

struct GoogleNaturalLanguageAPI {
    
    typealias AnalyzeEntitiesCompletion = (AnalyzeEntitiesResponse?, Error?) -> Void
    
    let key: String
    
//    private let endpointURL = URL(string: "https://language.googleapis.com/v1beta1/documents:analyzeEntities") // Beta
    private let analyzeEntitiesEndpoint = "https://language.googleapis.com/v1/documents:analyzeEntities"
    private let session = URLSession.shared
    
    func analyzeEntities(request: AnalyzeEntitiesRequest, completion: @escaping AnalyzeEntitiesCompletion) -> URLSessionTask {
        
        let url = URL(string: "\(analyzeEntitiesEndpoint)?key=\(key)")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: request.json, options: [])
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                throw ContentError.parse
//                let response = try AnalyzeEntitiesResponse(json: json)
//                completion(response, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}
 
 */
