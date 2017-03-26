//
//  MonkeyLearnEntitiesTextAnnotationServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/27.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

//import Foundation
//import MonkeyLearnEntitiesAPI
//
//extension FragmentType {
//    fileprivate init?(tag: MonkeyLearnEntitiesAPI.Tag) {
//        switch tag {
//        case .person:
//            self = .person
//            
//        case .organization:
//            self = .organization
//            
//        default:
//            return nil
//        }
//    }
//}

//extension Entity {
//    init(monkeyLearnEntity entity: MonkeyLearnEntitiesAPI.Entity, annotation: Annotation) {
//        self.content = entity.value
//        self.normalizedContent = entity.value
//        self.annotations = [annotation]
//    }
//}

//struct MonkeyLearnEntitiesTextAnnotationServiceAdapter: TextAnnotationService {
//    let service: MonkeyLearnEntitiesAPI
//    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) {
//        let text = request.text.content
//        service.fetchEntities(text: text) { (response, error) in
//            var text = request.text
//            if let entities = response?.entities {
//                self.annotate(text: &text, entities: entities)
//            }
//            let output = TextAnnotationResponse(text: text)
//            completion(output, error)
//        }
//    }
//    
//    private func annotate(text: inout AnnotatedText, entities: [MonkeyLearnEntitiesAPI.Entity]) {
//        for entity in entities {
//            annotate(text: &text, entity: entity)
//        }
//    }
//    
//    private func annotate(text: inout AnnotatedText, entity: MonkeyLearnEntitiesAPI.Entity) {
//        
//        guard let type = FragmentType(tag: entity.tag) else {
//            return
//        }
//
//        guard let range = text.content.range(of: entity.value) else {
//            return
//        }
//        
//        text.add(type: type, text: entity.value, in: range)
//    }
//
//}
