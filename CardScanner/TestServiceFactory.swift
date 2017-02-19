//
//  TestServiceFactory.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Contacts

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
                        content: "Steve Jobs"
                    )
                ],
                organizationEntities: [
                    Entity(
                        content: "Apple Inc."
                    )
                ],
                addressEntities: [
                    Entity(
                        content: placemark()
                    )
                ],
                phoneEntities: [
                    Entity(
                        content: "786-555-1212"
                    ),
                    Entity(
                        content: "786-555-3434"
                    )
                ],
                urlEntities: [
                    Entity(
                        content: URL(string: "http://apple.com")!
                    )
                ],
                emailEntities: [
                    Entity(
                        content: URL(string: "mailto:steve.jobs@apple.com")!
                    )
                ]
            ),
            error: nil
        )
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return MockAddressResolutionService(
            response: [placemark()],
            error: nil
        )
    }
    
    func placemark() -> CLPlacemark {
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
        
        return MKPlacemark(
            coordinate: coordinate,
            postalAddress: address
        )
    }
}
