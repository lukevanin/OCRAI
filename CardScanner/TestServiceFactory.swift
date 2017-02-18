//
//  TestServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts
import MapKit

struct TestServiceFactory: ServiceFactory {
    
    func imageAnnotationService() -> ImageAnnotationService? {
        return MockImageAnnotationService(
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
    }
    
    func textAnnotationService() -> TextAnnotationService? {
        return MockTextAnnotationService(
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
                addressEntities: [
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
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        
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
        
        return MockAddressResolutionService(
            response: [placemark],
            error: nil
        )
    }
}
