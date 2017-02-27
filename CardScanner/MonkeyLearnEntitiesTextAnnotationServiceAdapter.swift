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
    init(monkeyLearnEntity entity: MonkeyLearnEntitiesAPI.Entity) {
        self.offset = nil
        self.content = entity.value
    }
}

struct MonkeyLearnEntitiesTextAnnotationServiceAdapter: TextAnnotationService {
    let service: MonkeyLearnEntitiesAPI
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable {
        return service.fetchEntities(text: request.content) { (response, error) in
            guard let response = response else {
                completion(nil, error)
                return
            }
            let output = self.parseResponse(response)
            completion(output, nil)
        }
    }
    
    private func parseResponse(_ response: MonkeyLearnEntitiesAPI.Response) -> TextAnnotationResponse {
        return TextAnnotationResponse(
            personEntities: response.entities.filter({ $0.tag == .person }).map({ Entity(monkeyLearnEntity: $0) }),
            organizationEntities: response.entities.filter({ $0.tag == .organization }).map({ Entity(monkeyLearnEntity: $0) }),
            addressEntities: [],
            phoneEntities: [],
            urlEntities: [],
            emailEntities: []
        )
    }
}
