//
//  DefaultServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import GoogleNaturalLanguageAPI

struct DefaultServiceFactory: ServiceFactory {
    
    private let googleKey = "AIzaSyDTdcgltBmKzyR1n-eG2Vjc7L4vBBbpQ90"

    func imageAnnotationService() -> ImageAnnotationService? {
        return TestServiceFactory().imageAnnotationService()
    }
    
    func textAnnotationService() -> TextAnnotationService? {
//        let service = GoogleNaturalLanguageAPI(key: googleKey)
//        return GoogleNaturalLanguageServiceAdapter(service: service)
        return DataDetectorTextAnnotationService()
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return CoreLocationAddressResolutionService()
    }
}
