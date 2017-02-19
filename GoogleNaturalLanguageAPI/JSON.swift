//
//  JSON.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

extension GoogleNaturalLanguageAPI.EncodingType {
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

extension GoogleNaturalLanguageAPI.DocumentType {
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

extension GoogleNaturalLanguageAPI.Document {
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

extension GoogleNaturalLanguageAPI.AnalyzeEntitiesRequest {
    var json: [String: Any] {
        return [
            "document": document.json,
            "encodingType": encodingType.json
        ]
    }
}

extension GoogleNaturalLanguageAPI.EntityMentionType {
    init(json: Any) throws {
        guard let value = json as? String else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        switch value {
        case "TYPE_UNKNOWN":
            self = .unknown
        case "PROPER":
            self = .proper
        case "COMMON":
            self = .common
        default:
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
    }
}

extension GoogleNaturalLanguageAPI.TextSpan {
    init(json: Any) throws {
        guard
            let container = json as? [String: Any],
            let content = container["content"] as? String,
            let beginOffset = container["beginOffset"] as? Int
        else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        self.content = content
        self.beginOffset = beginOffset
    }
}

extension GoogleNaturalLanguageAPI.EntityMention {
    init(json: Any) throws {
        guard
            let container = json as? [String: Any],
            let type = container["type"] as? String,
            let text = container["text"]
        else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        self.type = try GoogleNaturalLanguageAPI.EntityMentionType(json: type)
        self.text = try GoogleNaturalLanguageAPI.TextSpan(json: text)
    }
}

extension GoogleNaturalLanguageAPI.EntityType {
    init(json: Any) throws {
        guard let value = json as? String else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        switch value {
        case "UNKNOWN":
            self = .unknown
        case "PERSON":
            self = .person
        case "LOCATION":
            self = .location
        case "ORGANIZATION":
            self = .organization
        case "EVENT":
            self = .event
        case "WORK_OF_ART":
            self = .art
        case "CONSUMER_GOOD":
            self = .consumergoods
        case "OTHER":
            self = .other
        default:
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
    }
}

extension GoogleNaturalLanguageAPI.Entity {
    init(json: Any) throws {
        guard
            let container = json as? [String: Any],
            let name = container["name"] as? String,
            let type = container["type"] as? String,
            let metadata = container["metadata"] as? [String: String],
            let salience = container["salience"] as? Double,
            let mentions = container["mentions"] as? [Any]
        else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        self.name = name
        self.type = try GoogleNaturalLanguageAPI.EntityType(json: type)
        self.metadata = metadata
        self.salience = salience
        self.mentions = try mentions.map { try GoogleNaturalLanguageAPI.EntityMention(json: $0) }
    }
}

extension GoogleNaturalLanguageAPI.AnalyzeEntitiesResponse {
    init(json: Any) throws {
        guard
            let container = json as? [String: Any],
            let entities = container["entities"] as? [Any],
            let language = container["language"] as? String
        else {
            throw GoogleNaturalLanguageAPI.APIError.parse
        }
        self.entities = try entities.map { try GoogleNaturalLanguageAPI.Entity(json: $0) }
        self.language = language
    }
}
