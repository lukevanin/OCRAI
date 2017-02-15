//
//  MockScannerService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts
import MapKit
import CoreLocation

extension ScannerService {
    static func mock(coreData: CoreDataStack) -> ScannerService {
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
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.33053,
            longitude: -122.02887
        )
        
        let address = CNMutablePostalAddress()
        address.street = "1 Infinite Loop"
        address.city = "Santa Clara"
        address.state = "California"
        address.postalCode = "95014"
        address.country = "United States"
        address.isoCountryCode = " US"
        
        let placemark = MKPlacemark(
            coordinate: coordinate,
            postalAddress: address
        )
        
        let addressResolutionService = MockAddressResolutionService(
            response: placemark,
            error: nil
        )
        
        let service = ScannerService(
            imageAnnotationService: imageAnnotationService,
            textAnnotationService: textAnnotationService,
            addressResolutionService: addressResolutionService,
            coreData: coreData,
            queue: OperationQueue()
        )
        return service;
    }
}
