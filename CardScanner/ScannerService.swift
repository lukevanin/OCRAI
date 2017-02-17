//
//  ScannerService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreLocation

struct ScannerService {
    
    enum State {
        case pending
        case active
        case completed
    }
    
    typealias ProgressHandler = (State) -> Void
    
    let factory: ServiceFactory
    let coreData: CoreDataStack
    let queue: OperationQueue
    
    init(factory: ServiceFactory, coreData: CoreDataStack, queue: OperationQueue? = nil) {
        self.factory = factory
        self.coreData = coreData
        self.queue = queue ?? OperationQueue()
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
    
    func scan(document identifier: String, progressHandler: @escaping ProgressHandler) -> Cancellable {
        let operation = ScanOperation(
            document: identifier,
            service: self,
            coreData: coreData,
            progress: progressHandler
        )
        queue.addOperation(operation)
        return operation
    }
    
    func annotateImage(image: Data, completion: @escaping (ImageAnnotationResponse?) -> Void) {
        guard let service = factory.imageAnnotationService() else {
            completion(nil)
            return
        }
        let request = ImageAnnotationRequest(
            image: image,
            features: [
                Feature(
                    type: .text
                )
            ]
        )
        service.annotate(request: request) { response, error in
            completion(response)
        }
    }
    
    func annotateText(text: String, completion: @escaping (TextAnnotationResponse?) -> Void) {
        guard let service = factory.textAnnotationService() else {
            completion(nil)
            return
        }
        let request = TextAnnotationRequest(
            content: text
        )
        service.annotate(request: request) { (response, error) in
            completion(response)
        }
    }
    
    func resolveAddress(address: String, completion: @escaping ([CLPlacemark]?) -> Void) {
        guard let service = factory.addressResolutionService() else {
            completion(nil)
            return
        }
        service.resolve(entity: address) { (places, error) in
            completion(places)
        }
    }
}
