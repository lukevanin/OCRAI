//
//  DefaultServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct DefaultServiceFactory: ServiceFactory {
    
    func imageAnnotationService() -> ImageAnnotationService? {
        return TestServiceFactory().imageAnnotationService()
    }
    
    func textAnnotationService() -> TextAnnotationService? {
        return TestServiceFactory().textAnnotationService()
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return CoreLocationAddressResolutionService()
    }
}
