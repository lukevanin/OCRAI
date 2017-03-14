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
                textAnnotations: makeAnnotatedText(),
                logoAnnotations: [],
                faceAnnotations: [],
                codeAnnotations: []
            ),
            error: nil
        )
    }
    
    func textAnnotationService() -> TextAnnotationService? {
        
        var text = AnnotatedText(lines: [
            /* 0 */ "Apple Inc.",
            /* 1 */ "apple.com",
            /* 2 */ "Steven Jobs",
            /* 3 */ "1 Infinite Loop",
            /* 4 */ "Cupertino, CA 95014",
            /* 5 */ "Tel: 786-555-1212",
            /* 6 */ "Fax: 786-555-3434",
            /* 7 */ "steve.jobs@apple.com"
            ])

        text.add(type: .organization, atLine: 0)
        text.add(type: .url, atLine: 1)
        text.add(type: .person, atLine: 2)
        text.add(type: .address, atLine: 3)
        text.add(type: .address, atLine: 4)
        text.add(type: .phoneNumber, atLine: 5)
        text.add(type: .phoneNumber, atLine: 6)
        text.add(type: .email, atLine: 5)
        
        
        return MockTextAnnotationService(
            response: TextAnnotationResponse(
                text: text
            ),
            error: nil
        )
    }
    
    func addressResolutionService() -> AddressResolutionService? {
        return MockAddressResolutionService(
            response: [makePlacemark()],
            error: nil
        )
    }
    
    func makeAnnotatedText() -> AnnotatedText {
        return AnnotatedText(
            lines: [
                "Apple Inc.",
                "apple.com",
                "Steven Jobs",
                "1 Infinite Loop",
                "Cupertino, CA 95014",
                "Tel: 786-555-1212",
                "Fax: 786-555-3434",
                "steve.jobs@apple.com",
                "@stevejobs"
                ]
            )
    }
    
    func makePlacemark() -> CLPlacemark {
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.33053,
            longitude: -122.02887
        )
        
        return MKPlacemark(
            coordinate: coordinate,
            postalAddress: makeAddress()
        )
    }
    
    func makeAddress() -> CNPostalAddress {
        let address = CNMutablePostalAddress()
        address.street = "1 Infinite Loop"
        address.city = "Santa Clara"
        address.state = "California"
        address.postalCode = "95014"
        address.country = "United States"
        address.isoCountryCode = " US"
        return address
    }
}
