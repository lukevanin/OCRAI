//
//  ServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

protocol ServiceFactory {
    func textAnnotationService() -> TextAnnotationService?
    func imageAnnotationService() -> ImageAnnotationService?
    func addressResolutionService() -> AddressResolutionService?
}
