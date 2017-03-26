//
//  GoogleNaturalLanguageServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreData
import GoogleNaturalLanguageAPI

extension FieldType {
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
        
        let content: Document
        
        func parse(response: GoogleNaturalLanguageAPI.AnalyzeEntitiesResponse) {
            response.entities.forEach(annotate)
        }
        
        private func annotate(_ entity: GoogleNaturalLanguageAPI.Entity) {
        
            guard let type = FieldType(entityType: entity.type) else {
                return
            }
            
            for mention in entity.mentions {
                annotate(mention: mention, type: type)
            }
        }
        
        private func annotate(mention: GoogleNaturalLanguageAPI.EntityMention, type: FieldType) {
            let mentionText = mention.text
            let offset = mentionText.beginOffset
            let length = mentionText.content.characters.count
            let range = NSRange(location: offset, length: length)
            content.annotate(
                type: type,
                text: mentionText.content,
                at: range
            )
        }
    }
    
    func annotate(content: Document, completion: @escaping (Bool, Error?) -> Void) {

        DispatchQueue.main.async { [content, service] in
            
            guard let text = content.text else {
                completion(false, nil)
                return
            }
        
            let serviceRequest = GoogleNaturalLanguageAPI.AnalyzeEntitiesRequest(
                encodingType: .utf16,
                document: GoogleNaturalLanguageAPI.Document(
                    type: .plaintext,
                    content: text
                ))
            
            service.analyzeEntities(request: serviceRequest) { (response, error) in
                
                guard let response = response else {
                    completion(false, error)
                    return
                }

                DispatchQueue.main.async {
                    let parser = ResponseParser(content: content)
                    parser.parse(response: response)
                    completion(true, nil)
                }
            }
        }
    }
}
