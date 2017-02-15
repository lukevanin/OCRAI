//
//  ScannerService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreLocation

struct DerivedAnnotations {
    var imageAnnotations: ImageAnnotationResponse?
    var textAnnotations: TextAnnotationResponse?
    var locations: [Location]?
    
    init(imageAnnotations: ImageAnnotationResponse? = nil, textAnnotations: TextAnnotationResponse? = nil, locations: [Location]? = nil) {
        self.imageAnnotations = imageAnnotations
        self.textAnnotations = textAnnotations
        self.locations = locations
    }
}

private class ScanOperation: AsyncOperation {
    
    private typealias FetchAnnotationsCompletion = (DerivedAnnotations?, Error?) -> Void
    
    private let image: UIImage
    private let service: ScannerService
    private let completion: ScannerService.Completion
    
    private var imageAnnotationTask: Cancellable?
    private var textAnnotationTask: Cancellable?
    private var addressResolutionTask: Cancellable?
    
    init(image: UIImage, service: ScannerService, completion: @escaping ScannerService.Completion) {
        self.image = image
        self.service = service
        self.completion = completion
    }
    
    fileprivate override func cancel() {
        imageAnnotationTask?.cancel()
        textAnnotationTask?.cancel()
        addressResolutionTask?.cancel()
        super.cancel()
    }
    
    fileprivate override func execute(completion: @escaping () -> Void) {
        annotate() { contact, error in
            if !self.isCancelled {
                self.completion(contact, error)
            }
            completion()
        }
    }
    
    private func annotate(completion: @escaping ScannerService.Completion) {
        fetchAnnotations() { annotations, error in
            guard let annotations = annotations else {
                completion(nil, error)
                return
            }
            
            let builder = DocumentBuilder(
                image: self.image,
                annotations: annotations
            )
            
            let document = builder.build()
            completion(document, nil)
        }
    }
    
    private func fetchAnnotations(completion: @escaping FetchAnnotationsCompletion) {
    
        let imageRequest = ImageAnnotationRequest(
            image: image,
            features: [
                Feature(
                    type: .text
                )
            ]
        )
        
        var output = DerivedAnnotations()
        
        imageAnnotationTask = service.annotateImage(request: imageRequest) { (imageResponse, error) in
            
            guard let imageResponse = imageResponse else {
                completion(nil, error)
                return
            }
            
            // Accumulate detected image annotations.
            output.imageAnnotations = imageResponse;
            
            // Annotate text components (ie identify names, addresses, phone numbers)
            guard let textAnnotation = imageResponse.textAnnotations.first else {
                // No text annotations to process.
                completion(output, nil)
                return
            }
            
            let textRequest = TextAnnotationRequest(
                content: textAnnotation.content
            )
            self.textAnnotationTask = self.service.annotateText(request: textRequest) { (textResponse, error) in
                
                guard let textResponse = textResponse else {
                    completion(output, error)
                    return
                }
                
                // Accumulate detected text annotations.
                output.textAnnotations = textResponse
                
                // Parse address components if present.
                guard let addressEntity = textResponse.addressEntites.first else {
                    // No address entities to process.
                    completion(output, error)
                    return
                }
                
                self.addressResolutionTask = self.service.resolveAddress(entity: addressEntity) { (location, error) in
                    
                    if let location = location {
                        output.locations = [location]
                    }
                    
                    completion(output, error)
                }
                
            }
        }
    }
}

struct ScannerService {
    
    typealias Completion = (Document?, Error?) -> Void
    
    let imageAnnotationService: ImageAnnotationService
    let textAnnotationService: TextAnnotationService
    let addressResolutionService: AddressResolutionService
    let queue: OperationQueue
    
    func cancelAllScans() {
        queue.cancelAllOperations()
    }
    
    func scan(image: UIImage, completion: @escaping Completion) -> Cancellable {
        let operation = ScanOperation(
            image: image,
            service: self,
            completion: completion
        )
        queue.addOperation(operation)
        return operation
    }
    
    fileprivate func annotateImage(request: ImageAnnotationRequest, completion: @escaping ImageAnnotationCompletion) -> Cancellable {
        return imageAnnotationService.annotate(request: request, completion: completion)
    }
    
    fileprivate func annotateText(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable {
        return textAnnotationService.annotate(request: request, completion: completion)
    }
    
    fileprivate func resolveAddress(entity: Entity, completion: @escaping AddressResolutionCompletion) -> Cancellable {
        return addressResolutionService.resolve(entity: entity, completion: completion)
    }
}
