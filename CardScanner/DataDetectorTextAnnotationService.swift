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
    
    // FIXME: Use address resolution service
    
    private let text: String
    private let completion: TextAnnotationCompletion
    private let operationGroup: DispatchGroup
    private let addressQueue: DispatchQueue
    private let geoCoder: CLGeocoder
    
    private var phoneNumbers = [Entity<String>]()
    private var urls = [Entity<URL>]()
    private var addresses = [Entity<CNPostalAddress>]()
    
    init(text: String, completion: @escaping TextAnnotationCompletion) {
        self.text = text
        self.completion = completion
        self.operationGroup = DispatchGroup()
        self.addressQueue = DispatchQueue(label: "AddressGeocode")
        self.geoCoder = CLGeocoder()
    }
    
    fileprivate override func execute(completion: @escaping AsyncOperation.Completion) {
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link, .address]
        let detector = try! NSDataDetector(types: types.rawValue)
        let content = text
        let range = NSRange(
            location: 0,
            length: content.characters.count
        )
        let matches = detector.matches(in: content, options: [], range: range)
        makePhoneNumbers(matches)
        makeUrls(matches)
        makeAddresses(matches)
        
        operationGroup.notify(queue: DispatchQueue.global()) {
            if !self.isCancelled {
                let response = TextAnnotationResponse(
                    personEntities: [],
                    organizationEntities: [],
                    addressEntities: self.addresses,
                    phoneEntities: self.phoneNumbers,
                    urlEntities: self.urls,
                    emailEntities: []
                )
                self.completion(response, nil)
            }
            completion()
        }
    }
    
    private func makePhoneNumbers(_ matches: [NSTextCheckingResult]) {
        let values = filter(matches) { $0.phoneNumber }
        let entities = values.map() { Entity(content: $0) }
        phoneNumbers.append(contentsOf: entities)
    }
    
    private func makeUrls(_ matches: [NSTextCheckingResult]) {
        let values = filter(matches) { $0.url }
        let entities = values.map() { Entity(content: $0) }
        urls.append(contentsOf: entities) // FIXME: Disambiguate email vs web URLs
    }
    
    private func makeAddresses(_ matches: [NSTextCheckingResult]) {
        let values = filter(matches) { $0.addressComponents }
        for value in values {
            makeAddress(value)
        }
    }
    
    private func makeAddress(_ entities: [String: String]) {
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
    
        let entity = Entity<CNPostalAddress>(content: address)
        self.addresses.append(entity)
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
    
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable {
        let operation = DataDetectorTextAnnotationOperation(
            text: request.content,
            completion: completion
        )
        operationQueue.addOperation(operation)
        return operation
    }
}
