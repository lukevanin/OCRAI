//
//  DataDetectorTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import Contacts
import CoreLocation

private class DataDetectorTextAnnotationOperation: AsyncOperation {
    
    private let text: AnnotatedText
    private let completion: TextAnnotationCompletion
    private let operationGroup: DispatchGroup
    
    private var phoneNumbers = [Entity]()
    private var urlAddresses = [Entity]()
    private var emailAddresses = [Entity]()
    private var postalAddresses = [Entity]()
    
    init(text: AnnotatedText, completion: @escaping TextAnnotationCompletion) {
        self.text = text
        self.completion = completion
        self.operationGroup = DispatchGroup()
    }
    
    fileprivate override func execute(completion: @escaping AsyncOperation.Completion) {
        
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link, .address]
        let detector = try! NSDataDetector(types: types.rawValue)
        let content = text.content
        let range = NSRange(
            location: 0,
            length: content.characters.count
        )
        let matches = detector.matches(in: content, options: [], range: range)
        makePhoneNumbers(matches)
        makeUrlAddresses(matches)
        makeEmailAddresses(matches)
        makePostalAddresses(matches)
        
        operationGroup.notify(queue: DispatchQueue.global()) {
            if !self.isCancelled {
                
                // FIXME: Detect dates
                let response = TextAnnotationResponse(
                    personEntities: [],
                    organizationEntities: [],
                    addressEntities: self.postalAddresses,
                    phoneEntities: self.phoneNumbers,
                    urlEntities: self.urlAddresses,
                    emailEntities: self.emailAddresses
                )
                self.completion(response, nil)
            }
            completion()
        }
    }
    
    private func makePhoneNumbers(_ matches: [NSTextCheckingResult]) {
        let entities = makeEntities(forMatches: matches) { $0.phoneNumber }
        phoneNumbers.append(contentsOf: entities)
    }
    
    private func makeUrlAddresses(_ matches: [NSTextCheckingResult]) {
        let entities = makeEntities(forMatches: matches) {
            guard let url = $0.url else {
                return nil
            }
            
            if let scheme = url.scheme, scheme == "mailto" {
                return nil
            }
            
            return url.absoluteString
        }
        
        urlAddresses.append(contentsOf: entities)
    }
    
    private func makeEmailAddresses(_ matches: [NSTextCheckingResult]) {
        let entities = makeEntities(forMatches: matches) {
            guard let url = $0.url, let scheme = url.scheme, scheme == "mailto" else {
                return nil
            }
            return url.absoluteString
        }
        
        emailAddresses.append(contentsOf: entities)
    }
    
    private func makePostalAddresses(_ matches: [NSTextCheckingResult]) {
        let entities = makeEntities(forMatches: matches) { match in
            guard let components = match.addressComponents else {
                return nil
            }
            return makeAddress(components)
        }
        
        postalAddresses.append(contentsOf: entities)
    }
    
    private func makeAddress(_ entities: [String: String]) -> String? {
        let address = CNMutablePostalAddress()
        
        if let street = entities[NSTextCheckingStreetKey] {
            address.street = street
        }
        
        if let city = entities[NSTextCheckingCityKey] {
            address.city = city
        }
        
        if let postalCode = entities[NSTextCheckingZIPKey] {
            address.postalCode = postalCode
        }
        
        if let country = entities[NSTextCheckingCountryKey] {
            address.country = country
        }
    
        let content = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
        return content
    }
    
    private func makeEntities(forMatches matches: [NSTextCheckingResult], normalize: (NSTextCheckingResult) -> String?) -> [Entity] {
        var entities = [Entity]()
        
        for match in matches {
            if let normalizedContent = normalize(match) {
                let content = textForMatch(match)
                let annotations = annotationsForMatch(match)
                let entity = Entity(
                    content: content,
                    normalizedContent: normalizedContent,
                    annotations: annotations
                )
                entities.append(entity)
            }
        }
        
        return entities
    }
    
    private func textForMatch(_ match: NSTextCheckingResult) -> String {
        if match.numberOfRanges > 1 {
            // FIXME: Handle multiple ranges in response
            fatalError("unsupported multiple ranges")
        }
        let range = text.convertRange(match.range)
        return text.getText(in: range)
    }
    
    private func annotationsForMatch(_ match: NSTextCheckingResult) -> [Annotation] {
        var output = [Annotation]()
        for i in 0 ..< match.numberOfRanges {
            let range = match.rangeAt(i)
            let annotations = annotationForRange(range)
            output.append(contentsOf: annotations)
        }
        return output
    }
    
    private func annotationForRange(_ range: NSRange) -> [Annotation] {
        return text.getAnnotations(forRange: text.convertRange(range))
    }

    private func filter<T>(_ matches: [NSTextCheckingResult], value: (NSTextCheckingResult) -> T?) -> [T] {
        var output = [T]()
        for match in matches {
            if let v = value(match) {
                output.append(v)
            }
        }
        return output
    }
}

struct DataDetectorTextAnnotationService: TextAnnotationService {
    let operationQueue: OperationQueue
    
    init(queue: OperationQueue? = nil) {
        self.operationQueue = queue ?? OperationQueue()
    }
    
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) {
        let operation = DataDetectorTextAnnotationOperation(
            text: request.text,
            completion: completion
        )
        operationQueue.addOperation(operation)
    }
}
