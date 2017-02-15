//
//  MockScannerService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts

extension ScannerService {
    static func mock() -> ScannerService {
        let imageAnnotationService = MockImageAnnotationService(
            response: ImageAnnotationResponse(
                textAnnotations: [
                    Annotation(
                        content: "Apple Inc., apple.com, Steve Jobs, 1 Infinite Loop, Cupertino, CA 95014, Tel: 786-555-1212, Fax: 786-555-3434, steve.jobs@apple.com, @stevejobs",
                        uri: nil,
                        bounds: Polygon(
                            vertices: []
                        )
                    )
                ],
                logoAnnotations: [],
                faceAnnotations: [],
                codeAnnotations: []
            ),
            error: nil
        )
        
        let textAnnotationService = MockTextAnnotationService(
            response: TextAnnotationResponse(
                personEntities: [
                    Entity(
                        offset: 0,
                        content: "Steve Jobs"
                    )
                ],
                organizationEntities: [
                    Entity(
                        offset: 0,
                        content: "Apple Inc."
                    )
                ],
                addressEntites: [
                    Entity(
                        offset: 0,
                        content: "1 Infinite Loop, Cupertino, CA 95014"
                    )
                ],
                phoneEntities: [
                    Entity(
                        offset: 0,
                        content: "786-555-1212"
                    ),
                    Entity(
                        offset: 0,
                        content: "786-555-3434"
                    )
                ],
                urlEntities: [
                    Entity(
                        offset: 0,
                        content: "apple.com"
                    )
                ],
                emailEntities: [
                    Entity(
                        offset: 0,
                        content: "steve.jobs@apple.com"
                    )
                ],
                atEntities: [
                    Entity(
                        offset: 0,
                        content: "@stevejobs"
                    )
                ]
            ),
            error: nil
        )
        
        var location = Location()
        location.subThroughfare = "1"
        location.throughfare = "Infinite Loop"
        location.subLocality = "Mission District"
        location.locality = "Cupertino"
        location.subAdministrativeArea = "Santa Clara"
        location.administrativeArea = "CA"
        location.postalCode = "95014"
        location.countryCode = "US"
        location.country = "United States"
        
        let addressResolutionService = MockAddressResolutionService(
            response: location,
            error: nil
        )
        
        let service = ScannerService(
            imageAnnotationService: imageAnnotationService,
            textAnnotationService: textAnnotationService,
            addressResolutionService: addressResolutionService,
            queue: OperationQueue()
        )
        return service;
    }
}
