//
//  GoogleNaturalLanguageServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import GoogleNaturalLanguageAPI

struct GoogleNaturalLanguageServiceAdapter: TextAnnotationService {
    let service: GoogleNaturalLanguageAPI
    
    struct ResponseParser {
        let text: AnnotatedText
        
        func parse(response: GoogleNaturalLanguageAPI.AnalyzeEntitiesResponse) -> TextAnnotationResponse {
            return TextAnnotationResponse(
                personEntities: textEntities(type: .person, forResponse: response),
                organizationEntities: textEntities(type: .organization, forResponse: response),
                addressEntities: [], // FIXME: Parse address to address components
                phoneEntities: [],
                urlEntities: [],
                emailEntities: []
            )
        }
        
        private func textEntities(type: GoogleNaturalLanguageAPI.EntityType, forResponse response: GoogleNaturalLanguageAPI.AnalyzeEntitiesResponse) -> [Entity] {
            var output = [Entity]()
            let entities = response.entities.filter() { $0.type == type }
            
            let content = self.text.content
            let contentUTF = content.utf16
            
            for entity in entities {
                for mention in entity.mentions {
                    let text = mention.text
                    let offset = text.beginOffset
                    let length = text.content.characters.count
                    let range = self.text.convertRange(NSRange(location: offset, length: length))
                    let annotations = self.text.getAnnotations(forRange: range)
                    output.append(
                        Entity(
                            content: text.content,
                            annotations: annotations
                        )
                    )
                }
            }
            
            return output
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
            completion(nil, error)
        }
    }
}
