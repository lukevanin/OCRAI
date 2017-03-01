//
//  MonkeyLearnEntitiesTextAnnotationServiceAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/27.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import MonkeyLearnEntitiesAPI

extension Entity {
    init(monkeyLearnEntity entity: MonkeyLearnEntitiesAPI.Entity, annotation: Annotation) {
        self.content = entity.value
        self.annotations = [annotation]
    }
}

struct MonkeyLearnEntitiesTextAnnotationServiceAdapter: TextAnnotationService {
    let service: MonkeyLearnEntitiesAPI
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) {
        
        let text = request.text.content
        
        service.fetchEntities(text: text) { (response, error) in
            
            var output = TextAnnotationResponse(
                personEntities: [],
                organizationEntities: [],
                addressEntities: [],
                phoneEntities: [],
                urlEntities: [],
                emailEntities: []
            )

            if let response = response {
                let personEntities = self.parseEntities(response.entities.filter { $0.tag == .person }, text: request.text)
                let organizationEntities = self.parseEntities(response.entities.filter { $0.tag == .organization }, text: request.text)
                output.personEntities.append(contentsOf: personEntities)
                output.organizationEntities.append(contentsOf: organizationEntities)
            }
            
            completion(output, nil)
        }
    }
    
    private func parseEntities(_ entities: [MonkeyLearnEntitiesAPI.Entity], text: AnnotatedText) -> [Entity] {
        var output = [Entity]()
        
        for entity in entities {
            // FIXME: Check for multiple matching occurrences of entity.
            if let range = text.content.range(of: entity.value) {
                let annotations = text.getAnnotations(forRange: range)
                output.append(
                    Entity(
                        content: entity.value,
                        annotations: annotations
                    )
                )
            }
        }
        
        return output
    }
    
}
