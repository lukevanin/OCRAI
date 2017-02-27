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

private let googleServiceKey = "AIzaSyDsS29DsE0nInrMwJqMEC29A2-_uoHAHAg"

private let monkeyLearnAccount = "ex_isnnZRbS"
private let monkeyLearnAuthorizationToken = "6f420a106bb97bd6973ed5f20cd637a59c46c1d0"

struct DefaultServiceFactory: ServiceFactory {
    
    func imageAnnotationService() -> ImageAnnotationService? {
        let service = GoogleVisionAPI(key: googleServiceKey)
        return GoogleVisionServiceAdapter(service: service)
    }
    
    func textAnnotationService() -> TextAnnotationService? {
//        let googleNaturalLanguageService = GoogleNaturalLanguageAPI(key: googleServiceKey)
//        let googleNaturalLanguageServiceAdapter = GoogleNaturalLanguageServiceAdapter(service: googleNaturalLanguageService)
        
        let monkeyLearnService = MonkeyLearnEntitiesAPI(account: monkeyLearnAccount, authorizationToken: monkeyLearnAuthorizationToken)
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
