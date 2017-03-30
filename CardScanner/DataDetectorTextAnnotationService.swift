//
//  DataDetectorTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  FIXME: Detect dates
//

import Foundation
import Contacts
import CoreLocation

private class DataDetectorTextAnnotationOperation: AsyncOperation {
    
    private let content: Document
    private let completion: TextAnnotationServiceCompletion
    
    init(content: Document, completion: @escaping TextAnnotationServiceCompletion) {
        self.content = content
        self.completion = completion
    }
    
    fileprivate override func execute(completion: @escaping AsyncOperation.Completion) {

        DispatchQueue.main.async { [content] in
            
            if let content = content.text {

                let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link, .address]
                let detector = try! NSDataDetector(types: types.rawValue)
                let range = NSRange(
                    location: 0,
                    length: content.characters.count
                )
                
                let matches = detector.matches(
                    in: content,
                    options: [],
                    range: range
                )
                
                self.annotatePhoneNumbers(matches)
                self.annotateUrlAddresses(matches)
                self.annotateEmailAddresses(matches)
                self.annotatePostalAddresses(matches)
            }
            
            if !self.isCancelled {
                self.completion(true, nil)
            }
            
            completion()
        }
    }
    
    private func annotatePhoneNumbers(_ matches: [NSTextCheckingResult]) {
        annotate(type: .phoneNumber, matches: matches) { $0.phoneNumber }
    }
    
    private func annotateUrlAddresses(_ matches: [NSTextCheckingResult]) {
        annotate(type: .url, matches: matches) {
            guard let url = $0.url else {
                return nil
            }
            
            if let scheme = url.scheme, scheme == "mailto" {
                return nil
            }
            
            return url.absoluteString
        }
    }
    
    private func annotateEmailAddresses(_ matches: [NSTextCheckingResult]) {
        annotate(type: .email, matches: matches) {
            guard let url = $0.url, let scheme = url.scheme, scheme == "mailto" else {
                return nil
            }
            return url.absoluteString
        }
    }
    
    private func annotatePostalAddresses(_ matches: [NSTextCheckingResult]) {
        annotate(matches: matches) { match in
            guard let components = match.addressComponents else {
                return nil
            }
            return makeAddress(components)
        }
    }
    
    private func makeAddress(_ entities: [String: String]) -> CNPostalAddress {
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
        
        return address
    }
    
    private func annotate(type: FieldType, matches: [NSTextCheckingResult], normalize: (NSTextCheckingResult) -> String?) {
        for match in matches {
            guard let normalizedText = normalize(match) else {
                continue
            }
            
            if match.numberOfRanges > 1 {
                // FIXME: Handle multiple ranges in response
                fatalError("unsupported multiple ranges")
            }
            
            content.annotate(
                type: type,
                text: normalizedText,
                at: match.range
            )
        }
    }
    
    private func annotate(matches: [NSTextCheckingResult], normalize: (NSTextCheckingResult) -> CNPostalAddress?) {
        for match in matches {
            guard let address = normalize(match) else {
                continue
            }
            
            if match.numberOfRanges > 1 {
                // FIXME: Handle multiple ranges in response
                fatalError("unsupported multiple ranges")
            }
            
            content.annotate(
                address: address,
                at: match.range
            )
        }
    }
}

struct DataDetectorTextAnnotationService: TextAnnotationService {
    let operationQueue: OperationQueue
    
    init(queue: OperationQueue? = nil) {
        self.operationQueue = queue ?? OperationQueue()
    }
    
    func annotate(content: Document, completion: @escaping TextAnnotationServiceCompletion) {
        let operation = DataDetectorTextAnnotationOperation(
            content: content,
            completion: completion
        )
        operationQueue.addOperation(operation)
    }
}
