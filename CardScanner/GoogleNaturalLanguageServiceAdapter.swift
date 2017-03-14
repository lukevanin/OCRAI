//
//  GoogleNaturalLanguageServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import GoogleNaturalLanguageAPI

extension FragmentType {
    fileprivate init?(entityType: GoogleNaturalLanguageAPI.EntityType) {
        switch entityType {
        case .person:
            self = .person
            
        case .organization:
            self = .organization
            
        default:
            return nil
        }
    }
}

struct GoogleNaturalLanguageServiceAdapter: TextAnnotationService {
    let service: GoogleNaturalLanguageAPI
    
    struct ResponseParser {
        let text: AnnotatedText
        
        func parse(response: GoogleNaturalLanguageAPI.AnalyzeEntitiesResponse) -> TextAnnotationResponse {
            var text = self.text
            annotate(text: &text, entities: response.entities)
            return TextAnnotationResponse(text: text)
        }
        
        private func annotate(text: inout AnnotatedText, entities: [GoogleNaturalLanguageAPI.Entity]) {
            for entity in entities {
                annotate(text: &text, entity: entity)
            }
        }
        
        private func annotate(text: inout AnnotatedText, entity: GoogleNaturalLanguageAPI.Entity) {
        
            guard let type = FragmentType(entityType: entity.type) else {
                return
            }
            
            for mention in entity.mentions {
                annotate(text: &text, mention: mention, type: type)
            }
        }
        
        private func annotate(text: inout AnnotatedText, mention: GoogleNaturalLanguageAPI.EntityMention, type: FragmentType) {
            let mentionText = mention.text
            let offset = mentionText.beginOffset
            let length = mentionText.content.characters.count
            let range = text.convertRange(NSRange(location: offset, length: length))
            text.add(type: type, text: mentionText.content, in: range)
        }
    }
    
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) {
        let text = request.text.content
        let serviceRequest = GoogleNaturalLanguageAPI.AnalyzeEntitiesRequest(
            encodingType: .utf16,
            document: GoogleNaturalLanguageAPI.Document(
                type: .plaintext,
                content: text
            ))
        service.analyzeEntities(request: serviceRequest) { (response, error) in
            guard let response = response else {
                completion(nil, error)
                return
            }
            let parser = ResponseParser(text: request.text)
            let output = parser.parse(response: response)
            completion(output, nil)
        }
    }
}
