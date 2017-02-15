//
//  DocumentBuilder.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/10.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class DocumentBuilder {
    
    private let image: UIImage
    private let annotations: DerivedAnnotations
    
    private var document: Document!
//    private var organization: String?
//    private var person: String?
//    private var photoImageData: Data?
//    private var notes = [String]()
//    private var urlValues = [CNLabeledValue<NSString>]()
//    private var emailValues = [CNLabeledValue<NSString>]()
//    private var phoneNumberValues = [CNLabeledValue<CNPhoneNumber>]()
//    private var addressValues = [CNLabeledValue<CNPostalAddress>]()
    
    init(image: UIImage, annotations: DerivedAnnotations) {
        self.image = image
        self.annotations = annotations
    }
    
    func build() -> Document {
        
        let imageData = UIImagePNGRepresentation(image)
        self.document = Document(
            image: imageData!
        )
        
        makeOrganization()
        makePerson()
        makeFaces()
        makeCodes()
        makeAddresses()
        makePhoneNumbers()
        makeEmailAddresses()
        makeURLs()
        
        return document
    }
    
    //
    //  Add organization from detected entities or detected image logo.
    //
    private func makeOrganization() {
        
        // Use detected orgs
        if let entities = annotations.textAnnotations?.organizationEntities {
            let organizations = entities.map { $0.content }
            document.organizations.append(contentsOf: organizations)
        }
        
        // TODO: Use orgs from detected logos
    }
    
    //
    //  Add person from text annotations.
    //
    private func makePerson() {
        guard let entities = annotations.textAnnotations?.personEntities else {
            return
        }
        let names = entities.map { $0.content }
        document.names.append(contentsOf: names)
    }

    //
    //  Add face as image data.
    //
    private func makeFaces() {
        guard let annotations = annotations.imageAnnotations?.faceAnnotations else {
            return
        }
        // FIXME:  Extract face images from image
    }
    
    //
    //  Add URL & metadata from detected codes.
    //
    private func makeCodes() {
        guard let annotations = annotations.imageAnnotations?.codeAnnotations else {
            return
        }
        for annotation in annotations {
            if let url = URL(string: annotation.content) {
                // Annotation is a valid URL
                // TODO: Distinguish between email and other URL type
                let value = Fragment(
                    label: nil,
                    content: url.absoluteString
                )
                document.urlAddresses.append(value)
            }
            else {
                // Annotation is not avalid URL.
                document.notes.append(annotation.content)
            }
        }
    }
    
    //
    //  Add person, organization, address, urls from text entities.
    //
    private func makeAddresses() {
        guard let locations = annotations.locations else {
            return
        }
        document.locations.append(contentsOf: locations)
    }
    
    //
    //  Add phone numbers
    //
    private func makePhoneNumbers() {
        guard let entities = annotations.textAnnotations?.phoneEntities else {
            return
        }
        let fragments = entities.map {
            Fragment(
                label: nil,
                content: $0.content
            )
        }
        document.phoneNumbers.append(contentsOf: fragments)
    }
    
    // 
    //  Add emai addresses
    //
    private func makeEmailAddresses() {
        guard let entities = annotations.textAnnotations?.emailEntities else {
            return
        }
        let fragments = entities.map {
            Fragment(
                label: nil,
                content: $0.content
            )
        }
        document.emailAddresses.append(contentsOf: fragments)
    }
    
    //
    //  Add web URLs
    //
    private func makeURLs() {
        guard let entities = annotations.textAnnotations?.urlEntities else {
            return
        }
        let fragments = entities.map {
            Fragment(
                label: nil,
                content: $0.content
            )
        }
        document.urlAddresses.append(contentsOf: fragments)
    }
}
