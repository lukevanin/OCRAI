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
import MicrosoftVision

struct DefaultServiceFactory: ServiceFactory {
    
    func imageAnnotationService() -> ImageAnnotationService {
//        let service = try! GoogleVisionAPI()
//        return GoogleVisionServiceAdapter(service: service)

        let service = try! MicrosoftVisionOCR()
        return MicrosoftVisionAdapter(service: service)
    }
    
    func textAnnotationService() -> TextAnnotationService {
        let googleNaturalLanguageService = try! GoogleNaturalLanguageAPI()
        let googleNaturalLanguageServiceAdapter = GoogleNaturalLanguageServiceAdapter(service: googleNaturalLanguageService)
        
//        let monkeyLearnService = try! MonkeyLearnEntitiesAPI()
//        let monkeyLearnAdapter = MonkeyLearnEntitiesTextAnnotationServiceAdapter(service: monkeyLearnService)
        
        let dataDetectorService = DataDetectorTextAnnotationService()
        return AggregateTextAnnotationService(services: [
                dataDetectorService,
                googleNaturalLanguageServiceAdapter,
                ])
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return CoreLocationAddressResolutionService()
    }
}
