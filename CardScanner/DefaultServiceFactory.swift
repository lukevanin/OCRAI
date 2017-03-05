//
//  DefaultServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import GoogleVisionAPI
import GoogleNaturalLanguageAPI
import MonkeyLearnEntitiesAPI

struct DefaultServiceFactory: ServiceFactory {
    
    func imageAnnotationService() -> ImageAnnotationService? {
        let service = try! GoogleVisionAPI()
        return GoogleVisionServiceAdapter(service: service)
    }
    
    func textAnnotationService() -> TextAnnotationService? {
        let googleNaturalLanguageService = try! GoogleNaturalLanguageAPI()
        let googleNaturalLanguageServiceAdapter = GoogleNaturalLanguageServiceAdapter(service: googleNaturalLanguageService)
        
        let monkeyLearnService = try! MonkeyLearnEntitiesAPI()
        let monkeyLearnAdapter = MonkeyLearnEntitiesTextAnnotationServiceAdapter(service: monkeyLearnService)
        
        let dataDetectorService = DataDetectorTextAnnotationService()
        return AggregateTextAnnotationService(
            services: [
                
//                .descriptor(
//                    service: googleNaturalLanguageServiceAdapter,
//                    combine: { original, response in
//                        return TextAnnotationResponse(
//                            personEntities: response.personEntities,
//                            organizationEntities: response.organizationEntities,
//                            addressEntities: original.addressEntities,
//                            phoneEntities: original.phoneEntities,
//                            urlEntities: original.urlEntities,
//                            emailEntities: original.emailEntities
//                        )
//                }),
                
                .descriptor(
                    service: monkeyLearnAdapter,
                    combine: { original, response in
                        return TextAnnotationResponse(
                            personEntities: response.personEntities,
                            organizationEntities: response.organizationEntities,
                            addressEntities: original.addressEntities,
                            phoneEntities: original.phoneEntities,
                            urlEntities: original.urlEntities,
                            emailEntities: original.emailEntities
                        )
                }),
                
                .descriptor(
                    service: dataDetectorService,
                    combine: { original, response in
                        TextAnnotationResponse(
                            personEntities: original.personEntities,
                            organizationEntities: original.organizationEntities,
                            addressEntities: response.addressEntities,
                            phoneEntities: response.phoneEntities,
                            urlEntities: response.urlEntities,
                            emailEntities: response.emailEntities
                        )
                })
            ]
        )
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return CoreLocationAddressResolutionService()
    }
}
