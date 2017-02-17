//
//  DocumentBuilder.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/10.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

/*
import UIKit
import CoreData

class DocumentBuilder {
    
    private let image: UIImage
    private let annotations: DerivedAnnotations
    private let context: NSManagedObjectContext
    
    private var document: Document!
    
    init(image: UIImage, annotations: DerivedAnnotations, context: NSManagedObjectContext) {
        self.image = image
        self.annotations = annotations
        self.context = context
    }
    
    func build() -> Document {
        
        let imageData = UIImagePNGRepresentation(image) // FIXME: Use JPEG compression
        self.document = Document(
            imageData: imageData!,
            context: context
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
            for entity in entities {
                let fragment = TextFragment(
                    type: .organization,
                    value: entity.content,
                    context: context
                )
                document.addToTextFragments(fragment)
            }
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
        for entity in entities {
            let fragment = TextFragment(
                type: .person,
                value: entity.content,
                context: context
            )
            document.addToTextFragments(fragment)
        }
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
            let fragment: TextFragment
            if let url = URL(string: annotation.content) {
                // Annotation is a valid URL
                // TODO: Distinguish between email and other URL type
                fragment = TextFragment(
                    type: .url,
                    value: url.absoluteString,
                    context: context
                )
            }
            else {
                // Annotation is not avalid URL.
                fragment = TextFragment(
                    type: .note,
                    value: annotation.content,
                    context: context
                )
            }
            document.addToTextFragments(fragment)
        }
    }
    
    //
    //  Add person, organization, address, urls from text entities.
    //
    private func makeAddresses() {
        guard let entities = annotations.locations else {
            return
        }
        for entity in entities {
            let location = LocationFragment(
                placemark: entity,
                context: context
            )
            document.addToLocations(location)
        }
    }
    
    //
    //  Add phone numbers
    //
    private func makePhoneNumbers() {
        guard let entities = annotations.textAnnotations?.phoneEntities else {
            return
        }
        for entity in entities {
            let fragment = TextFragment(
                type: .phoneNumber,
                value: entity.content,
                context: context
            )
            document.addToTextFragments(fragment)
        }
    }
    
    // 
    //  Add emai addresses
    //
    private func makeEmailAddresses() {
        guard let entities = annotations.textAnnotations?.emailEntities else {
            return
        }
        for entity in entities {
            let fragment = TextFragment(
                type: .email,
                value: entity.content,
                context: context
            )
            document.addToTextFragments(fragment)
        }
    }
    
    //
    //  Add web URLs
    //
    private func makeURLs() {
        guard let entities = annotations.textAnnotations?.urlEntities else {
            return
        }
        for entity in entities {
            let fragment = TextFragment(
                type: .url,
                value: entity.content,
                context: context
            )
            document.addToTextFragments(fragment)
        }
    }
}
 */
